// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The decisions behind collapsing menu bar items: which press means what, how
/// wide a collapsed separator has to be, when a collapse is allowed to happen,
/// and when an expanded bar folds itself back up. None of it touches a real
/// status item, so every branch is walkable here.
enum MenuBarHidingTests {
    static func run(_ suite: TestSuite) {
        presses(suite)
        widths(suite)
        arrangement(suite)
        countdown(suite)
        hover(suite)
        strings(suite)
    }

    private static func presses(_ suite: TestSuite) {
        suite.expect(MenuBarHidingActionResolver.action(isRightClick: false, optionPressed: false) == .toggle,
                     "a plain click toggles the collapsed section")
        suite.expect(MenuBarHidingActionResolver.action(isRightClick: true, optionPressed: false) == .contextMenu,
                     "a right click opens the menu")
        suite.expect(MenuBarHidingActionResolver.action(isRightClick: false, optionPressed: true) == .toggleSections,
                     "option-click toggles the always hidden section")
        suite.expect(MenuBarHidingActionResolver.action(isRightClick: true, optionPressed: true) == .toggleSections,
                     "option wins over the mouse button so the section toggle has one meaning")
    }

    private static func widths(_ suite: TestSuite) {
        suite.expect(MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: nil)
                         == MenuBarHidingLayout.fallbackScreenWidth * 2,
                     "a collapse with no screen width yet still covers a full bar")
        suite.expect(MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: 100)
                         == MenuBarHidingLayout.minimumCollapsedSeparatorLength,
                     "a narrow display still collapses past the floor instead of leaving icons visible")
        suite.expect(MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: 1440) == 2880,
                     "the collapse width covers the widest attached display twice over")
        suite.expect(MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: 8000)
                         == MenuBarHidingLayout.maximumStatusItemLength,
                     "an ultrawide rig stays inside AppKit's maximum status item length")
        suite.expect(MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: .nan)
                         == MenuBarHidingLayout.fallbackScreenWidth * 2,
                     "a non-finite screen width falls back instead of producing a NaN length")
        suite.expect(MenuBarHidingLayout.separatorLength(collapsed: false, widestScreenWidth: 1440)
                         == MenuBarHidingLayout.expandedSeparatorLength,
                     "an expanded separator is a thin line, not a screen-wide gap")
        suite.expect(MenuBarHidingLayout.separatorLength(collapsed: true, widestScreenWidth: 1440) == 2880,
                     "a collapsed separator takes the covering width")

        suite.expect(MenuBarHidingLayout.alwaysHiddenSeparatorLength(enabled: false, hidingSection: true,
                                                                    widestScreenWidth: 1440) == 0,
                     "an unnecessary always hidden separator keeps a zero-width slot")
        suite.expect(MenuBarHidingLayout.alwaysHiddenSeparatorLength(enabled: true, hidingSection: false,
                                                                    widestScreenWidth: 1440)
                         == MenuBarHidingLayout.expandedSeparatorLength,
                     "a shown always hidden section still shows its separator")
        suite.expect(MenuBarHidingLayout.alwaysHiddenSeparatorLength(enabled: true, hidingSection: true,
                                                                    widestScreenWidth: 1440) == 2880,
                     "a section meant to stay hidden is covered by its separator")

        suite.expect(MenuBarHidingLayout.separatorDidWiden(requestedLength: 2880, windowWidth: 2880),
                     "a separator that took its width is what a working mechanism looks like")
        suite.expect(!MenuBarHidingLayout.separatorDidWiden(requestedLength: 2880, windowWidth: 12),
                     "a separator stuck at its expanded width means the system ignored the request")
        suite.expect(!MenuBarHidingLayout.separatorDidWiden(requestedLength: 2880, windowWidth: nil),
                     "an unmeasurable separator is not evidence either way")
        suite.expect(!MenuBarHidingLayout.separatorDidWiden(requestedLength: 12, windowWidth: 12),
                     "a request that was never a collapse is not judged as one")
    }

    private static func arrangement(_ suite: TestSuite) {
        suite.expect(MenuBarHidingLayout.isOnHiddenSide(100, of: 200, isLeftToRight: true),
                     "left of the boundary is the hidden side in a left-to-right bar")
        suite.expect(!MenuBarHidingLayout.isOnHiddenSide(300, of: 200, isLeftToRight: true),
                     "right of the boundary stays visible in a left-to-right bar")
        suite.expect(MenuBarHidingLayout.isOnHiddenSide(300, of: 200, isLeftToRight: false),
                     "a mirrored bar hides what is right of the boundary")
        suite.expect(!MenuBarHidingLayout.isOnHiddenSide(nil, of: 200, isLeftToRight: true),
                     "an item with no position cannot be judged as hidden")
        suite.expect(!MenuBarHidingLayout.isOnHiddenSide(.nan, of: 200, isLeftToRight: true),
                     "a non-finite position cannot be judged as hidden")

        suite.expect(MenuBarHidingLayout.isArrangementValid(separatorX: 100, arrowX: 200, isLeftToRight: true),
                     "a separator behind the arrow can hide what is past it")
        suite.expect(!MenuBarHidingLayout.isArrangementValid(separatorX: 300, arrowX: 200, isLeftToRight: true),
                     "a separator in front of the arrow would collapse the arrow itself and is refused")
        suite.expect(MenuBarHidingLayout.isArrangementValid(separatorX: 300, arrowX: 200, isLeftToRight: false),
                     "the mirrored arrangement is valid on the mirrored side")
        suite.expect(!MenuBarHidingLayout.isArrangementValid(separatorX: nil, arrowX: 200, isLeftToRight: true),
                     "an unplaced separator cannot hide anything")

        suite.expect(MenuBarHidingSection.section(ofItemX: 100, separatorX: 200, isLeftToRight: true) == .hidden,
                     "an item past the separator is in the hidden section")
        suite.expect(MenuBarHidingSection.section(ofItemX: 300, separatorX: 200, isLeftToRight: true) == .visible,
                     "an item on the arrow's side of the separator is visible")
    }

    private static func countdown(_ suite: TestSuite) {
        suite.expect(MenuBarHidingAutoCollapse.sanitizedSeconds(MenuBarHidingAutoCollapse.defaultSeconds)
                         == MenuBarHidingAutoCollapse.defaultSeconds,
                     "the default wait survives sanitizing")
        suite.expect(MenuBarHidingAutoCollapse.sanitizedSeconds(0)
                         == MenuBarHidingAutoCollapse.minimumSeconds,
                     "a saved zero wait is raised to the shortest allowed one")
        suite.expect(MenuBarHidingAutoCollapse.sanitizedSeconds(10_000)
                         == MenuBarHidingAutoCollapse.maximumSeconds,
                     "an absurd saved wait is lowered to the longest allowed one")
        suite.expect(MenuBarHidingAutoCollapse.sanitizedSeconds(.nan)
                         == MenuBarHidingAutoCollapse.defaultSeconds,
                     "an unreadable saved wait falls back to the default")
        suite.expect(MenuBarHidingAutoCollapse.sanitizedSeconds(7.6) == 8,
                     "a fractional saved wait lands on a whole second")

        suite.expect(MenuBarHidingAutoCollapse.shouldArmTimer(enabled: true, collapsed: false),
                     "expanding arms the countdown")
        suite.expect(!MenuBarHidingAutoCollapse.shouldArmTimer(enabled: true, collapsed: true),
                     "a collapse the user asked for is not undone by a timer")
        suite.expect(!MenuBarHidingAutoCollapse.shouldArmTimer(enabled: false, collapsed: false),
                     "no countdown runs while auto collapse is off")

        suite.expect(MenuBarHidingAutoCollapse.shouldWait(pointerInMenuBar: true, appIsActive: false),
                     "a collapse waits while the pointer is inside the menu bar")
        suite.expect(MenuBarHidingAutoCollapse.shouldWait(pointerInMenuBar: false, appIsActive: true),
                     "a collapse waits while one of our windows is in front")
        suite.expect(!MenuBarHidingAutoCollapse.shouldWait(pointerInMenuBar: false, appIsActive: false),
                     "nothing in the way means the collapse happens")
    }

    private static func hover(_ suite: TestSuite) {
        let screen = MenuBarHidingScreen(frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
                                         visibleFrame: CGRect(x: 0, y: 0, width: 1440, height: 875))
        suite.expect(MenuBarHidingHover.isPointerInMenuBar(pointer: CGPoint(x: 700, y: 890), screens: [screen]),
                     "the pointer in the band above the visible frame is in the menu bar")
        suite.expect(!MenuBarHidingHover.isPointerInMenuBar(pointer: CGPoint(x: 700, y: 800), screens: [screen]),
                     "the pointer inside the desktop area is not in the menu bar")
        suite.expect(!MenuBarHidingHover.isPointerInMenuBar(pointer: CGPoint(x: -20, y: 890), screens: [screen]),
                     "a pointer left of the display is not over its menu bar")

        let fullscreen = MenuBarHidingScreen(frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
                                             visibleFrame: CGRect(x: 0, y: 0, width: 1440, height: 900))
        suite.expect(!MenuBarHidingHover.isPointerInMenuBar(pointer: CGPoint(x: 700, y: 895), screens: [fullscreen]),
                     "a hidden menu bar has no band to hover, so hovering must not expand")

        suite.expect(!MenuBarHidingHover.isPointerInMenuBar(pointer: CGPoint(x: CGFloat.nan, y: CGFloat.nan),
                                                            screens: [screen]),
                     "an unreadable pointer position never triggers an expansion")
        suite.expect(MenuBarHidingHover.dwellSeconds > 0,
                     "a passing pointer needs to rest before the bar expands")
    }

    private static func strings(_ suite: TestSuite) {
        let english = FeatureStrings.menuBarHiding(.enUS)
        suite.expect(!english.section.isEmpty && !english.placementHint.isEmpty,
                     "the English hiding strings exist")
        for language in AppLanguage.allCases {
            let translated = FeatureStrings.menuBarHiding(language)
            let fields = LocalizationTests.fields(translated)
            suite.expect(!fields.isEmpty, "\(language.rawValue): hiding strings read as fields")
            let empty = fields.filter { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            suite.expect(empty.isEmpty,
                         "\(language.rawValue): missing text in \(empty.keys.sorted().joined(separator: ", "))")
            let dashes = fields.filter { $0.value.contains("\u{2014}") }
            suite.expect(dashes.isEmpty,
                         "\(language.rawValue): em-dash in \(dashes.keys.sorted().joined(separator: ", "))")
            if language != .enUS {
                suite.expect(translated.section != english.section,
                             "\(language.rawValue): the card title is translated")
                suite.expect(translated.enableToggle != english.enableToggle,
                             "\(language.rawValue): the main switch is translated")
            }
        }
    }
}
