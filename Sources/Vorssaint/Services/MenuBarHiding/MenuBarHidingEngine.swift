// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// The status items an engine borrows. The service owns and recreates them; an
/// engine only ever changes their widths, which is the whole mechanism.
protocol MenuBarHidingItemProvider: AnyObject {
    var toggleItem: NSStatusItem? { get }
    var separatorItem: NSStatusItem? { get }
    var alwaysHiddenItem: NSStatusItem? { get }
}

/// How a hiding mechanism collapses the bar. Behind a protocol because the
/// mechanism is a property of the running macOS: separator widths are honoured
/// up to macOS 26, and newer releases are reported not to reflow around an
/// inflated item any more. When that is confirmed, a different engine can be
/// dropped in without the service, the settings or the menu changing.
protocol MenuBarHidingEngine: AnyObject {
    var state: MenuBarHidingState { get }

    func collapse(completion: @escaping (MenuBarHidingCollapseResult) -> Void)
    func expand()

    /// Whether the always hidden section exists at all, and whether it is meant
    /// to stay hidden while the hidden section is shown.
    func updateAlwaysHiddenSection(enabled: Bool, hidingSection: Bool)

    /// Whether the user's `⌘`-drag arrangement lets anything be hidden: the
    /// separator has to sit on the hidden side of the arrow.
    var isArrangementValid: Bool { get }

    /// Whether the always hidden separator sits beyond the regular one. Without
    /// that the always hidden section cannot be told apart from the hidden one.
    var isAlwaysHiddenSeparatorPlaced: Bool { get }

    /// Display geometry changed. A collapsed bar has to take the new width,
    /// otherwise a display hot-plug leaves the separator at a stale size.
    func invalidateLayout()
}

/// Hides icons by inflating the separator until everything on its far side
/// leaves the visible bar. The bar reflows around any length, so the width only
/// has to cover the widest attached display.
///
/// The state is derived from the live separator width rather than stored, so it
/// cannot drift when the width is recomputed while collapsed.
final class LengthMenuBarHidingEngine: MenuBarHidingEngine {
    private weak var items: MenuBarHidingItemProvider?
    private let widestScreenWidth: () -> CGFloat
    private let isLeftToRight: () -> Bool
    private let separatorWindowWidth: (NSStatusItem) -> CGFloat?
    private let log: (String) -> Void

    /// Set when this macOS demonstrably ignores the separator width. Latched:
    /// the behaviour will not change mid-session, and every later collapse would
    /// only repeat the same failed measurement.
    private var mechanismUnavailable = false

    /// One measurement per item generation: cheap, and it answers a question
    /// whose answer is fixed for the life of the process.
    private var didVerifyMechanism = false

    private var alwaysHiddenEnabled = false
    private var hidingAlwaysHiddenSection = false

    init(items: MenuBarHidingItemProvider,
         widestScreenWidth: @escaping () -> CGFloat = {
             NSScreen.screens.map(\.frame.width).max() ?? MenuBarHidingLayout.fallbackScreenWidth
         },
         isLeftToRight: @escaping () -> Bool = {
             NSApplication.shared.userInterfaceLayoutDirection == .leftToRight
         },
         separatorWindowWidth: @escaping (NSStatusItem) -> CGFloat? = { $0.button?.window?.frame.width },
         log: @escaping (String) -> Void = { NSLog("MenuBarHiding: %@", $0) }) {
        self.items = items
        self.widestScreenWidth = widestScreenWidth
        self.isLeftToRight = isLeftToRight
        self.separatorWindowWidth = separatorWindowWidth
        self.log = log
    }

    var state: MenuBarHidingState {
        if mechanismUnavailable { return .unavailable }
        guard let separator = items?.separatorItem else { return .expanded }
        return separator.length > MenuBarHidingLayout.expandedSeparatorLength ? .collapsed : .expanded
    }

    func collapse(completion: @escaping (MenuBarHidingCollapseResult) -> Void) {
        guard let separator = items?.separatorItem else {
            completion(.unavailable)
            return
        }
        guard !mechanismUnavailable else {
            completion(.unavailable)
            return
        }
        // Without the separator on the hidden side of the arrow, inflating it
        // takes the arrow with it and leaves the user nothing to click.
        guard isArrangementValid else {
            log("separator is not on the hidden side of the arrow; arrange it with Command-drag")
            completion(.unavailable)
            return
        }
        let requested = MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: widestScreenWidth())
        separator.length = requested
        completion(.collapsed)
        verifyMechanismIfNeeded(requested: requested)
    }

    func expand() {
        items?.separatorItem?.length = MenuBarHidingLayout.expandedSeparatorLength
        applyAlwaysHiddenSection()
    }

    func updateAlwaysHiddenSection(enabled: Bool, hidingSection: Bool) {
        alwaysHiddenEnabled = enabled
        hidingAlwaysHiddenSection = hidingSection
        applyAlwaysHiddenSection()
    }

    func invalidateLayout() {
        guard state == .collapsed else { return }
        items?.separatorItem?.length =
            MenuBarHidingLayout.collapsedSeparatorLength(widestScreenWidth: widestScreenWidth())
    }

    var isArrangementValid: Bool {
        MenuBarHidingLayout.isArrangementValid(separatorX: itemX(items?.separatorItem),
                                               arrowX: itemX(items?.toggleItem),
                                               isLeftToRight: isLeftToRight())
    }

    var isAlwaysHiddenSeparatorPlaced: Bool {
        MenuBarHidingLayout.isOnHiddenSide(itemX(items?.alwaysHiddenItem),
                                           of: itemX(items?.separatorItem),
                                           isLeftToRight: isLeftToRight())
    }

    private func applyAlwaysHiddenSection() {
        guard let alwaysHidden = items?.alwaysHiddenItem else { return }
        alwaysHidden.length = MenuBarHidingLayout.alwaysHiddenSeparatorLength(
            enabled: alwaysHiddenEnabled,
            hidingSection: hidingAlwaysHiddenSection,
            widestScreenWidth: widestScreenWidth()
        )
    }

    /// After a collapse, confirm on the next runloop tick (so layout has
    /// settled) that the separator actually claimed its width. A macOS that
    /// ignores `NSStatusItem.length` leaves the bar untouched, which looks like
    /// a broken toggle; failing here turns it into an explained state instead.
    private func verifyMechanismIfNeeded(requested: CGFloat) {
        guard !didVerifyMechanism else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.state == .collapsed, let separator = self.items?.separatorItem else { return }
            // An item that has no window yet (the first tick of a launch) has no
            // width to judge, so it does not use up the one measurement.
            guard let width = self.separatorWindowWidth(separator) else { return }
            self.didVerifyMechanism = true
            guard !MenuBarHidingLayout.separatorDidWiden(requestedLength: requested, windowWidth: width) else {
                return
            }
            self.log("separator stayed at \(Int(width))pt after asking for \(Int(requested))pt; "
                     + "this macOS does not reflow around an inflated status item")
            self.mechanismUnavailable = true
            // Fail open: never leave the icons hidden behind a mechanism that
            // is not doing anything.
            separator.length = MenuBarHidingLayout.expandedSeparatorLength
            self.applyAlwaysHiddenSection()
        }
    }

    private func itemX(_ item: NSStatusItem?) -> CGFloat? {
        item?.button?.window?.frame.midX
    }
}
