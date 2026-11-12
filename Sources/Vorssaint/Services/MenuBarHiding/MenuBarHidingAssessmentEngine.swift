// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// Something whose lifetime keeps a concealment assertion up. Dropping the
/// last reference would also work, but an explicit invalidate is deterministic:
/// the icons come back on the same runloop turn the user asked for.
protocol MenuBarHidingConcealment: AnyObject {
    func invalidate()
}

/// The assessment-mode facility as the engine sees it. A protocol so the
/// production decision path can be driven in the harness with a fake that
/// records allowlists and answers on command, instead of only testing the pure
/// set algebra next to it.
protocol MenuBarHidingAssessmentConcealing: AnyObject {
    var isAvailable: Bool { get }
    func conceal(allowing allowed: Set<String>,
                 completion: @escaping (Result<any MenuBarHidingConcealment,
                                               MenuBarHidingAssessmentRuntime.Failure>) -> Void)
}

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
final class MenuBarHidingAssessmentRuntime: MenuBarHidingAssessmentConcealing {
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

    /// A live assertion. Holding it keeps the concealment up; dropping it
    /// reveals the icons again.
    final class Token: MenuBarHidingConcealment {
        private let assertion: AnyObject

        fileprivate init(assertion: AnyObject) {
            self.assertion = assertion
        }

        deinit {
            invalidate()
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

    /// Resolves the framework callback against the main-queue timeout exactly
    /// once. Both arrive from different queues, so the flag needs a lock: a
    /// plain `Bool` raced, and the loser could activate a second token after
    /// the winner had already been handed out.
    private final class SettlementGate {
        private let lock = NSLock()
        private var settled = false

        func claim() -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !settled else { return false }
            settled = true
            return true
        }
    }

    /// Activates an assertion permitting exactly `allowed`, concealing the rest.
    /// The completion is delivered on the main queue.
    func conceal(allowing allowed: Set<String>,
                 completion: @escaping (Result<any MenuBarHidingConcealment, Failure>) -> Void) {
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

        let gate = SettlementGate()
        let settle: (Result<any MenuBarHidingConcealment, Failure>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        let handler: @convention(block) (Any?) -> Void = { error in
            guard gate.claim() else { return }
            if let error {
                _ = assertion.perform(Self.invalidateSelector)
                settle(.failure(.rejected(String(describing: error))))
            } else {
                settle(.success(Token(assertion: assertion)))
            }
        }
        _ = assertion.perform(Self.activateSelector, with: configuration, with: handler)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.activationTimeout) {
            guard gate.claim() else { return }
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
    private let runtime: any MenuBarHidingAssessmentConcealing
    /// The running set the production path reads. Injected so the harness can
    /// drive `runningAppsChanged()` with a known before/after set.
    private let runningBundleIDs: () -> Set<String>
    /// Zero in tests, where a runloop is not available to fire the coalescing
    /// timer; the production default stays below perceptibility.
    private let reapplyDelay: TimeInterval
    private let log: (String) -> Void

    private var hiddenBundleIDs: Set<String>
    private var token: (any MenuBarHidingConcealment)?
    /// The allowlist that went into the live token. `needsReapply` has to
    /// compare against this, not against a freshly computed allowlist: the
    /// freshly computed one subtracts the same hidden apps, which makes the
    /// predicate tautologically false and silently drops every launch.
    private(set) var appliedAllowlist: Set<String> = []
    private var runningAppsObservation: NSKeyValueObservation?
    private var reapplyWorkItem: DispatchWorkItem?
    private var terminateObserver: NSObjectProtocol?
    /// Identifies the activation in flight. `nil` when none is, including after
    /// a reveal or a teardown that cancelled one.
    private var activeActivation: Int?
    /// A re-apply asked for while an activation was in flight. Coalesced: one
    /// pending flag, not a queue, because only the newest running set matters.
    private var pendingReapply = false
    /// Bumped by every activation, reveal and teardown. A completion whose
    /// generation is stale invalidates whatever it brought back instead of
    /// installing it over the user's decision.
    private var generation = 0

    init(items: MenuBarHidingItemProvider,
         hiddenBundleIDs: Set<String>,
         runtime: any MenuBarHidingAssessmentConcealing = MenuBarHidingAssessmentRuntime.shared,
         runningBundleIDs: @escaping () -> Set<String> = {
             Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
         },
         reapplyDelay: TimeInterval = 0.4,
         log: @escaping (String) -> Void = { NSLog("MenuBarHiding: %@", $0) }) {
        self.items = items
        self.hiddenBundleIDs = hiddenBundleIDs
        self.runtime = runtime
        self.runningBundleIDs = runningBundleIDs
        self.reapplyDelay = reapplyDelay
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
            // There is nothing to conceal yet. Say so where the caller can
            // surface it, and leave the state alone: pretending to collapse
            // hides the fact that a choice is missing.
            log("no apps are marked hidden; choose some in Settings first")
            completion(.unavailable)
            stateDidChange?()
            return
        }
        guard state != .collapsed, activeActivation == nil else {
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
        // Cancels an activation the user overtook. Its completion may still
        // arrive; the generation check makes it invalidate the late token
        // instead of installing it.
        generation &+= 1
        activeActivation = nil
        pendingReapply = false
        reapplyWorkItem?.cancel()
        reapplyWorkItem = nil
        token?.invalidate()
        token = nil
        appliedAllowlist = []
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
        // Any assertion still in flight belongs to a feature that is now off.
        // The generation bump makes its completion invalidate itself rather
        // than leave icons concealed after teardown.
        generation &+= 1
        activeActivation = nil
        pendingReapply = false
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
        appliedAllowlist = []
        state = .expanded
    }

    // MARK: - Assertion lifetime

    /// Puts a new assertion up before invalidating the old one: an app concealed
    /// on both sides of a change never flickers into view.
    private func applyAssertion(completion: @escaping (Result<Void, MenuBarHidingAssessmentRuntime.Failure>) -> Void) {
        // The facility stalls MenuBarAgent while an assertion is applied, so
        // overlapping activations are not allowed. The request is not dropped:
        // it is remembered and re-run as soon as this one settles.
        guard activeActivation == nil else {
            pendingReapply = true
            return
        }
        generation &+= 1
        let activation = generation
        activeActivation = activation
        let running = runningBundleIDs()
        let allowed = MenuBarHidingAssessment.allowlist(running: Array(running), hidden: hiddenBundleIDs)
        log("activating assertion: allowing \(allowed.count) apps, hiding \(hiddenBundleIDs.count)")
        runtime.conceal(allowing: allowed) { [weak self] result in
            guard let self else { return }
            if self.activeActivation == activation {
                self.activeActivation = nil
            }
            // A completed activation the user already cancelled (reveal, stop,
            // or a newer activation) must not become the live token.
            guard activation == self.generation else {
                if case let .success(lateToken) = result {
                    lateToken.invalidate()
                }
                self.runPendingReapplyIfNeeded()
                return
            }
            switch result {
            case let .success(newToken):
                let previous = self.token
                self.token = newToken
                previous?.invalidate()
                self.appliedAllowlist = allowed
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
            self.runPendingReapplyIfNeeded()
        }
    }

    /// The set `runningAppsChanged` reads. Internal so the harness can call the
    /// same entry point KVO calls, rather than only re-testing the pure helper.
    func runningAppsChanged() {
        guard state == .collapsed else { return }
        let running = runningBundleIDs()
        guard MenuBarHidingAssessment.needsReapply(running: running,
                                                   allowed: appliedAllowlist,
                                                   hidden: hiddenBundleIDs) else {
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
        if reapplyDelay <= 0 {
            work.perform()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + reapplyDelay, execute: work)
        }
    }

    /// Runs a request that arrived while an activation was in flight, now that
    /// the activation has settled. Only runs while the bar is still collapsed:
    /// a reveal clears the flag before this can.
    private func runPendingReapplyIfNeeded() {
        guard pendingReapply else { return }
        pendingReapply = false
        guard state == .collapsed, activeActivation == nil else { return }
        scheduleReapply()
    }
}
