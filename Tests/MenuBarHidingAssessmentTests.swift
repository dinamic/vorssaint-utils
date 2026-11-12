// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The pure decisions behind the macOS 27 assessment-mode engine: which
/// mechanism a macOS gets, whether the private facility is usable, how the
/// allowlist is computed, when it has to be rebuilt, and what a successful or
/// refused activation means for the published state. None of it loads the
/// private framework or touches a status item.
enum MenuBarHidingAssessmentTests {
    static func run(_ suite: TestSuite) {
        availability(suite)
        allowlist(suite)
        reapply(suite)
        transitions(suite)
    }

    private static func availability(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.availability(osMajorVersion: 26, classesLoaded: true)
                         == .unsupportedOS,
                     "macOS 26 is below the assessment-mode facility")
        suite.expect(MenuBarHidingAssessment.availability(osMajorVersion: 27, classesLoaded: false)
                         == .frameworkMissing,
                     "macOS 27 without MenuBarClientCore reports the framework as missing")
        suite.expect(MenuBarHidingAssessment.availability(osMajorVersion: 27, classesLoaded: true)
                         == .available,
                     "macOS 27 with every class and selector present is available")
        suite.expect(MenuBarHidingAssessment.availability(osMajorVersion: 28, classesLoaded: true)
                         == .available,
                     "a later macOS keeps the facility available")

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

    private static func transitions(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAssessment.stateAfterActivation(succeeded: true) == .collapsed,
                     "a successful activation collapses the bar")
        suite.expect(MenuBarHidingAssessment.stateAfterActivation(succeeded: false) == .unavailable,
                     "a refused or timed-out activation is unavailable, not a silent no-op")
        suite.expect(MenuBarHidingAssessment.stateAfterReveal() == .expanded,
                     "revealing always returns to expanded")
    }
}
