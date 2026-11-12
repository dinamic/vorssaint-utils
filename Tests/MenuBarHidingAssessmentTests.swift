// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// The decisions behind the macOS 27 assessment-mode engine, plus the engine's
/// own production path driven through a fake facility: which mechanism a macOS
/// gets, how the allowlist is computed, when a launch has to rebuild it, what
/// the activation lifecycle does when it overlaps a launch, a reveal or a
/// teardown, and what a successful or refused activation means for the
/// published state. Nothing here touches the private framework or a status item.
enum MenuBarHidingAssessmentTests {
    static func run(_ suite: TestSuite) {
        mechanism(suite)
        allowlist(suite)
        reapply(suite)
        engineReapply(suite)
        engineLifecycle(suite)
        transitions(suite)
    }

    private static func mechanism(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.mechanism(osMajorVersion: 26, classesLoaded: true) == .width,
                     "the width engine is the pre-27 fallback")
        suite.expect(MenuBarHidingAssessment.mechanism(osMajorVersion: 27, classesLoaded: true) == .assessment,
                     "macOS 27 selects the assessment engine")
        suite.expect(MenuBarHidingAssessment.mechanism(osMajorVersion: 27, classesLoaded: false) == .assessment,
                     "macOS 27 still selects the assessment engine so it can report unavailable")
        suite.expect(MenuBarHidingAssessment.systemItemIndices == 0...8,
                     "system items 0 through 8 stay allowed")
    }

    private static func allowlist(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a", "b", "c"], hidden: ["b"])
                         == ["a", "c"],
                     "the allowlist is every running app except the hidden ones")
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a", "b"], hidden: [])
                         == ["a", "b"],
                     "with nothing hidden every running app is allowed")
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a", "b"], hidden: ["a", "b"]).isEmpty,
                     "hiding every running app leaves an empty allowlist")
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a", "a", "b"], hidden: ["b"])
                         == ["a"],
                     "duplicate bundle identifiers collapse")
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a", nil, "b"], hidden: [])
                         == ["a", "b"],
                     "an app without a bundle identifier cannot be named and is never allowed")
        suite.expect(MenuBarHidingAssessment.allowlist(running: ["a"], hidden: ["not-running"])
                         == ["a"],
                     "a hidden app that is not running does not remove anything")
    }

    private static func reapply(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.needsReapply(running: ["a", "b"], allowed: ["a"], hidden: []),
                     "an app that launched after the assertion went up needs a re-apply")
        suite.expect(!MenuBarHidingAssessment.needsReapply(running: ["a", "b"], allowed: ["a", "b"], hidden: []),
                     "an allowlist that already names every running app is current")
        suite.expect(!MenuBarHidingAssessment.needsReapply(running: ["a", "b"], allowed: ["a"], hidden: ["b"]),
                     "a hidden app missing from the allowlist is intentional, not stale")
        suite.expect(MenuBarHidingAssessment.needsReapply(running: ["a", "b", "c"], allowed: ["a"], hidden: ["b"]),
                     "a new visible app still triggers a re-apply when another app is hidden")
    }

    /// Drives the method KVO calls, not just `needsReapply`. The production bug
    /// was that the engine fed the freshly computed allowlist to the predicate,
    /// which made it tautologically false even though the live token held a
    /// stale snapshot.
    private static func engineReapply(_ suite: TestSuite) {
        let concealer = FakeConcealer()
        var running: Set<String> = ["a", "hidden"]
        let engine = makeEngine(hidden: ["hidden"], running: { running }, concealer: concealer)

        var result: MenuBarHidingCollapseResult?
        engine.collapse { result = $0 }
        suite.expect(result == .collapsed, "the fake facility lets the engine collapse")
        suite.expect(engine.appliedAllowlist == ["a"],
                     "the engine remembers the allowlist that the live token was given")

        running.insert("new")
        engine.runningAppsChanged()
        suite.expect(concealer.allowlists.count == 2,
                     "a launch while concealed drives a second activation through the production path")
        suite.expect(concealer.allowlists.last == ["a", "new"],
                     "the re-applied allowlist includes the app that launched")

        // An app that quits needs no activation, and neither does another call
        // with the same running set: the applied allowlist is now current.
        running.remove("new")
        engine.runningAppsChanged()
        suite.expect(concealer.allowlists.count == 2,
                     "no re-apply is requested when the applied allowlist still covers the running set")
    }

    private static func engineLifecycle(_ suite: TestSuite) {
        // A launch that arrives during an activation is queued, not dropped,
        // and the queued work uses the newest running set.
        let concealer = FakeConcealer()
        var running: Set<String> = ["a", "hidden"]
        let engine = makeEngine(hidden: ["hidden"], running: { running }, concealer: concealer)
        engine.collapse { _ in }
        suite.expect(concealer.allowlists.count == 1, "the first collapse activated once")

        concealer.autoSucceed = false
        running.insert("b")
        engine.runningAppsChanged()
        suite.expect(concealer.allowlists.count == 2, "the first re-apply is in flight")

        running.insert("c")
        engine.runningAppsChanged()
        suite.expect(concealer.allowlists.count == 2,
                     "a launch during the activation does not start an overlapping one")
        concealer.completeNext()
        suite.expect(concealer.allowlists.count == 3,
                     "the queued re-apply runs as soon as the activation settles")
        suite.expect(concealer.allowlists.last == ["a", "b", "c"],
                     "the queued re-apply uses the newest running set")

        // Reveal while an activation is in flight: the late token must be
        // invalidated, not installed over the reveal.
        let revealConcealer = FakeConcealer()
        var revealRunning: Set<String> = ["a", "hidden"]
        let revealEngine = makeEngine(hidden: ["hidden"], running: { revealRunning },
                                      concealer: revealConcealer)
        revealEngine.collapse { _ in }
        revealConcealer.autoSucceed = false
        revealRunning.insert("b")
        revealEngine.runningAppsChanged()
        revealEngine.expand()
        let lateToken = FakeToken()
        revealConcealer.completeNext(with: lateToken)
        suite.expect(revealEngine.state == .expanded,
                     "an activation that settles after a reveal does not collapse the bar again")
        suite.expect(lateToken.isInvalidated,
                     "the token from an activation the user cancelled is invalidated")
        suite.expect(revealEngine.appliedAllowlist.isEmpty,
                     "a reveal forgets the applied allowlist")

        // Teardown while an activation is in flight: same guarantee.
        let stopConcealer = FakeConcealer()
        var stopRunning: Set<String> = ["a", "hidden"]
        let stopEngine = makeEngine(hidden: ["hidden"], running: { stopRunning },
                                    concealer: stopConcealer)
        stopEngine.collapse { _ in }
        stopConcealer.autoSucceed = false
        stopRunning.insert("b")
        stopEngine.runningAppsChanged()
        stopEngine.stop()
        let tornDownToken = FakeToken()
        stopConcealer.completeNext(with: tornDownToken)
        suite.expect(tornDownToken.isInvalidated,
                     "an assertion that arrives after teardown is invalidated")
        suite.expect(stopEngine.state == .expanded,
                     "teardown leaves the published state expanded")

        // Nothing selected: the click reports unavailable instead of silently
        // pretending a collapse happened.
        let emptyConcealer = FakeConcealer()
        let emptyEngine = makeEngine(hidden: [], running: { ["a"] }, concealer: emptyConcealer)
        var emptyResult: MenuBarHidingCollapseResult?
        emptyEngine.collapse { emptyResult = $0 }
        suite.expect(emptyResult == .unavailable,
                     "collapsing with no apps selected reports unavailable")
        suite.expect(emptyConcealer.allowlists.isEmpty,
                     "collapsing with no apps selected does not ask the facility for anything")
    }

    private static func transitions(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.stateAfterActivation(succeeded: true) == .collapsed,
                     "a successful activation collapses the bar")
        suite.expect(MenuBarHidingAssessment.stateAfterActivation(succeeded: false) == .unavailable,
                     "a refused or timed-out activation is unavailable, not a silent no-op")
        suite.expect(MenuBarHidingAssessment.stateAfterReveal() == .expanded,
                     "revealing always returns to expanded")
    }

    private static func makeEngine(hidden: Set<String>,
                                   running: @escaping () -> Set<String>,
                                   concealer: FakeConcealer) -> AssessmentMenuBarHidingEngine {
        AssessmentMenuBarHidingEngine(items: FakeItems(),
                                      hiddenBundleIDs: hidden,
                                      runtime: concealer,
                                      runningBundleIDs: running,
                                      reapplyDelay: 0,
                                      log: { _ in })
    }
}

// MARK: - Fakes

private final class FakeItems: MenuBarHidingItemProvider {
    var toggleItem: NSStatusItem? { nil }
    var separatorItem: NSStatusItem? { nil }
    var alwaysHiddenItem: NSStatusItem? { nil }
}

private final class FakeToken: MenuBarHidingConcealment {
    private(set) var isInvalidated = false

    func invalidate() {
        isInvalidated = true
    }
}

/// Answers immediately by default, or holds completions so a test can act while
/// an activation is in flight.
private final class FakeConcealer: MenuBarHidingAssessmentConcealing {
    var isAvailable = true
    var autoSucceed = true
    private(set) var allowlists: [Set<String>] = []
    private var pending: [(Result<any MenuBarHidingConcealment,
                                  MenuBarHidingAssessmentRuntime.Failure>) -> Void] = []

    func conceal(allowing allowed: Set<String>,
                 completion: @escaping (Result<any MenuBarHidingConcealment,
                                               MenuBarHidingAssessmentRuntime.Failure>) -> Void) {
        allowlists.append(allowed)
        if autoSucceed {
            completion(.success(FakeToken()))
        } else {
            pending.append(completion)
        }
    }

    func completeNext(with token: FakeToken = FakeToken()) {
        guard !pending.isEmpty else { return }
        pending.removeFirst()(.success(token))
    }
}
