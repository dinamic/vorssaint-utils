// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// The macOS 27 concealment facility, loaded defensively.
///
/// macOS 27 ships an allowlist-based menu bar concealment behind the private
/// `MenuBarClientCore` framework: hold an assertion naming the bundle
/// identifiers that may show items and MenuBarAgent conceals everything else.
/// No layout is touched, so unlike the width mechanism there is no dead space,
/// nothing to calibrate and no separator to place.
///
/// The facility is private, so every class and selector is checked before use
/// and the whole thing reports unavailable rather than trapping if a future
/// build moves it. The approach is adapted from Ice, Thaw and justhide (all
/// GPLv3, as is Vorssaint); the implementation here is our own.
final class MenuBarHidingAssessmentRuntime {
    static let shared = MenuBarHidingAssessmentRuntime()

    private static let frameworkPath =
        "/System/Library/PrivateFrameworks/MenuBarClientCore.framework/MenuBarClientCore"
    private static let configureSelector =
        NSSelectorFromString("initWithAllowedSystemItems:allowedBundleIdentifiers:")
    private static let activateSelector =
        NSSelectorFromString("activateWithConfiguration:completionHandler:")
    private static let invalidateSelector = NSSelectorFromString("invalidate")

    /// Applying an assertion stalls MenuBarAgent for 100-150 ms. Three seconds
    /// without an answer means it is not coming.
    private static let activationTimeout: TimeInterval = 3

    private struct Classes {
        let configuration: AnyClass
        let assertion: AnyClass
    }

    private let classes: Classes?

    private init() {
        guard dlopen(Self.frameworkPath, RTLD_NOW) != nil,
              let configuration = NSClassFromString("MBAssessmentModeConfiguration"),
              let assertion = NSClassFromString("MBAssessmentModeAssertion"),
              configuration.instancesRespond(to: Self.configureSelector),
              assertion.instancesRespond(to: Self.activateSelector),
              assertion.instancesRespond(to: Self.invalidateSelector)
        else {
            classes = nil
            return
        }
        classes = Classes(configuration: configuration, assertion: assertion)
    }

    var isAvailable: Bool { classes != nil }

    var availability: MenuBarHidingAssessmentAvailability {
        MenuBarHidingAssessment.availability(
            osMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            classesLoaded: isAvailable
        )
    }

    /// A live assertion. Holding it keeps the concealment up; dropping it
    /// reveals the icons again.
    final class Token {
        private let assertion: AnyObject

        fileprivate init(assertion: AnyObject) {
            self.assertion = assertion
        }

        func invalidate() {
            _ = assertion.perform(MenuBarHidingAssessmentRuntime.invalidateSelector)
        }
    }

    enum Failure: LocalizedError {
        case unavailable
        case rejected(String)
        case timedOut

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "MenuBarClientCore assessment mode is unavailable"
            case let .rejected(detail):
                return "the assertion was rejected: \(detail)"
            case .timedOut:
                return "the assertion never answered"
            }
        }
    }

    /// Activates an assertion permitting exactly `allowed`, concealing the rest.
    /// The completion is delivered on the main queue.
    func conceal(allowing allowed: Set<String>,
                 completion: @escaping (Result<Token, Failure>) -> Void) {
        guard let classes else {
            completion(.failure(.unavailable))
            return
        }
        let systemItems = MenuBarHidingAssessment.systemItemIndices.map { NSNumber(value: $0) } as NSArray
        let allowed = allowed.sorted()

        guard let configuration = (classes.configuration.alloc() as AnyObject)
                .perform(Self.configureSelector, with: systemItems, with: allowed as NSArray)?
                .takeUnretainedValue(),
              let assertion = (classes.assertion.alloc() as AnyObject)
                .perform(NSSelectorFromString("init"))?
                .takeUnretainedValue()
        else {
            completion(.failure(.unavailable))
            return
        }

        var settled = false
        let settle: (Result<Token, Failure>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        let handler: @convention(block) (Any?) -> Void = { error in
            guard !settled else { return }
            settled = true
            if let error {
                _ = assertion.perform(Self.invalidateSelector)
                settle(.failure(.rejected(String(describing: error))))
            } else {
                settle(.success(Token(assertion: assertion)))
            }
        }
        _ = assertion.perform(Self.activateSelector, with: configuration, with: handler)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.activationTimeout) {
            guard !settled else { return }
            settled = true
            _ = assertion.perform(Self.invalidateSelector)
            settle(.failure(.timedOut))
        }
    }
}

/// Hides icons on macOS 27 by holding an assessment-mode assertion whose
/// allowlist names every running app except the ones the user chose to hide.
///
/// Concealment is per app, not positional: there is no separator to drag and no
/// section boundary. The allowlist is a snapshot, so it is re-applied when apps
/// launch; the new assertion goes up before the old one comes down so an app
/// concealed on both sides of a change never flickers into view.
final class AssessmentMenuBarHidingEngine: MenuBarHidingEngine {
    var stateDidChange: (() -> Void)?

    private(set) var state: MenuBarHidingState

    private weak var items: MenuBarHidingItemProvider?
    private let runtime: MenuBarHidingAssessmentRuntime
    private let log: (String) -> Void

    private var hiddenBundleIDs: Set<String>
    private var token: MenuBarHidingAssessmentRuntime.Token?
    private var runningAppsObservation: NSKeyValueObservation?
    private var reapplyWorkItem: DispatchWorkItem?
    private var terminateObserver: NSObjectProtocol?
    private var isActivating = false

    init(items: MenuBarHidingItemProvider,
         hiddenBundleIDs: Set<String>,
         runtime: MenuBarHidingAssessmentRuntime = .shared,
         log: @escaping (String) -> Void = { NSLog("MenuBarHiding: %@", $0) }) {
        self.items = items
        self.hiddenBundleIDs = hiddenBundleIDs
        self.runtime = runtime
        self.log = log
        self.state = runtime.isAvailable ? .expanded : .unavailable

        // `NSWorkspace.didLaunchApplicationNotification` was measured not to
        // fire for LSUIElement apps, and a menu bar agent is exactly the kind of
        // app this is about. `runningApplications` sees them.
        runningAppsObservation = NSWorkspace.shared.observe(\.runningApplications,
                                                            options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.runningAppsChanged() }
        }
        terminateObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.stop()
        }
    }

    deinit {
        reapplyWorkItem?.cancel()
        runningAppsObservation?.invalidate()
        if let terminateObserver { NotificationCenter.default.removeObserver(terminateObserver) }
        token?.invalidate()
    }

    func collapse(completion: @escaping (MenuBarHidingCollapseResult) -> Void) {
        guard runtime.isAvailable else {
            state = .unavailable
            completion(.unavailable)
            stateDidChange?()
            return
        }
        guard !hiddenBundleIDs.isEmpty else {
            log("no apps are marked hidden; choose some in Settings first")
            completion(.unavailable)
            return
        }
        guard state != .collapsed, !isActivating else {
            completion(state == .collapsed ? .collapsed : .unavailable)
            return
        }
        applyAssertion { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.state = MenuBarHidingAssessment.stateAfterActivation(succeeded: true)
                completion(.collapsed)
            case let .failure(error):
                self.log("conceal failed: \(error.localizedDescription)")
                self.state = MenuBarHidingAssessment.stateAfterActivation(succeeded: false)
                completion(.unavailable)
            }
            self.stateDidChange?()
        }
    }

    func expand() {
        reapplyWorkItem?.cancel()
        reapplyWorkItem = nil
        token?.invalidate()
        token = nil
        state = MenuBarHidingAssessment.stateAfterReveal()
        stateDidChange?()
    }

    func updateAlwaysHiddenSection(enabled: Bool, hidingSection: Bool) {
        // macOS 27 concealment is per app; there is no second section to place.
    }

    func updateHiddenBundleIDs(_ ids: Set<String>) {
        guard ids != hiddenBundleIDs else { return }
        hiddenBundleIDs = ids
        guard state == .collapsed else { return }
        if ids.isEmpty {
            expand()
        } else {
            scheduleReapply()
        }
    }

    func invalidateLayout() {
        // Nothing positional to resize.
    }

    var isArrangementValid: Bool { true }

    func stop() {
        reapplyWorkItem?.cancel()
        reapplyWorkItem = nil
        runningAppsObservation?.invalidate()
        runningAppsObservation = nil
        if let observer = terminateObserver {
            NotificationCenter.default.removeObserver(observer)
            terminateObserver = nil
        }
        token?.invalidate()
        token = nil
        state = .expanded
    }

    // MARK: - Assertion lifetime

    /// Puts a new assertion up before invalidating the old one: an app concealed
    /// on both sides of a change never flickers into view.
    private func applyAssertion(completion: @escaping (Result<Void, MenuBarHidingAssessmentRuntime.Failure>) -> Void) {
        guard !isActivating else { return }
        isActivating = true
        let running = NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier)
        let allowed = MenuBarHidingAssessment.allowlist(running: running, hidden: hiddenBundleIDs)
        log("activating assertion: allowing \(allowed.count) apps, hiding \(hiddenBundleIDs.count)")
        runtime.conceal(allowing: allowed) { [weak self] result in
            guard let self else { return }
            self.isActivating = false
            switch result {
            case let .success(newToken):
                let previous = self.token
                self.token = newToken
                previous?.invalidate()
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func runningAppsChanged() {
        guard state == .collapsed else { return }
        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        let allowed = MenuBarHidingAssessment.allowlist(running: Array(running), hidden: hiddenBundleIDs)
        guard MenuBarHidingAssessment.needsReapply(running: running, allowed: allowed, hidden: hiddenBundleIDs) else {
            return
        }
        scheduleReapply()
    }

    /// Coalesced: several apps can arrive at once (a login, or an app that
    /// brings agents with it), and each refresh stalls MenuBarAgent.
    private func scheduleReapply() {
        reapplyWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.state == .collapsed else { return }
            self.applyAssertion { result in
                if case let .failure(error) = result {
                    self.log("re-applying the allowlist failed: \(error.localizedDescription)")
                }
            }
        }
        reapplyWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
}
