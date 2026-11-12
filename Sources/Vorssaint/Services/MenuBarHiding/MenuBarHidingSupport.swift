// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

/// Collapsing menu bar items the way Hidden Bar does it. The user holds the
/// collapse arrow next to the section they want hidden and a hairline separator
/// marks the boundary: inflating that separator pushes everything on its far
/// side off the visible bar, and shrinking it brings the icons back.
///
/// Everything here is a decision, not a system call, so the harness can walk
/// every branch without putting status items in a real menu bar.
enum MenuBarHidingAction: Equatable {
    case toggle
    /// Right click: the menu that reaches settings and the off switch.
    case contextMenu
    /// Option click: whether the always hidden section is shown at all.
    case toggleSections
}

enum MenuBarHidingActionResolver {
    /// Option wins over the other two because it is the only press whose
    /// meaning does not depend on which button was used. A synthesized
    /// accessibility press carries no button, and arrives as a plain click,
    /// so assistive technology can always collapse and expand the bar.
    static func action(isRightClick: Bool, optionPressed: Bool) -> MenuBarHidingAction {
        if optionPressed { return .toggleSections }
        return isRightClick ? .contextMenu : .toggle
    }
}

/// What a hiding engine is doing right now. `unavailable` is a real state, not
/// an error: a macOS that ignores the separator width leaves the bar exactly as
/// it was, and the interface has to say so instead of looking broken.
enum MenuBarHidingState: Equatable {
    case expanded
    case collapsed
    case unavailable
}

enum MenuBarHidingCollapseResult: Equatable {
    case collapsed
    case unavailable
}

/// The widths and comparisons the width mechanism is built from.
enum MenuBarHidingLayout {
    /// Width the boundary separator keeps while the bar is expanded: wide
    /// enough to see and click, narrow enough to read as a divider.
    static let expandedSeparatorLength: CGFloat = 12

    /// A collapsed separator has to cover the whole status area of the widest
    /// attached display. Below this floor a bar with many icons would still
    /// show the ones nearest the edge.
    static let minimumCollapsedSeparatorLength: CGFloat = 500

    /// AppKit's documented ceiling for `NSStatusItem.length`. Asking for more
    /// is ignored outright, which would leave the collapsing silently undone.
    static let maximumStatusItemLength: CGFloat = 10_000

    /// Used when no screen width is available yet, e.g. the first tick of a
    /// launch, so the collapsed width is still usable instead of zero.
    static let fallbackScreenWidth: CGFloat = 1728

    /// The collapsed width for a set of displays. The menu bar repeats on every
    /// display, so the widest one decides: sizing from the focused screen
    /// leaks hidden icons on a wider screen. `frame.width` rather than
    /// `visibleFrame.width`, because the bar spans the full frame.
    static func collapsedSeparatorLength(widestScreenWidth: CGFloat?) -> CGFloat {
        let width = usableWidth(widestScreenWidth)
        return min(max(width * 2, minimumCollapsedSeparatorLength), maximumStatusItemLength)
    }

    static func separatorLength(collapsed: Bool, widestScreenWidth: CGFloat?) -> CGFloat {
        collapsed ? collapsedSeparatorLength(widestScreenWidth: widestScreenWidth)
                  : expandedSeparatorLength
    }

    /// The always hidden boundary needs covering width only while the section
    /// is meant to stay hidden. When it is shown, it is a thin line like the
    /// regular separator; when the section is off entirely it keeps its slot at
    /// zero width, which is what preserves the spot the user dragged it to.
    static func alwaysHiddenSeparatorLength(enabled: Bool,
                                            hidingSection: Bool,
                                            widestScreenWidth: CGFloat?) -> CGFloat {
        guard enabled else { return 0 }
        return hidingSection ? collapsedSeparatorLength(widestScreenWidth: widestScreenWidth)
                             : expandedSeparatorLength
    }

    /// Whether `itemX` sits on the side of `boundaryX` that a collapse hides.
    /// Left of the boundary in a left-to-right bar, right of it in a mirrored
    /// one. An item that is not on screen has no position to judge.
    static func isOnHiddenSide(_ itemX: CGFloat?, of boundaryX: CGFloat?, isLeftToRight: Bool) -> Bool {
        guard let itemX, let boundaryX, itemX.isFinite, boundaryX.isFinite else { return false }
        return isLeftToRight ? itemX <= boundaryX : itemX >= boundaryX
    }

    /// Whether the arrangement can hide anything at all: the separator has to
    /// be on the hidden side of the arrow, or inflating it would push the arrow
    /// itself off the bar and leave nothing to click.
    static func isArrangementValid(separatorX: CGFloat?,
                                   arrowX: CGFloat?,
                                   isLeftToRight: Bool) -> Bool {
        isOnHiddenSide(separatorX, of: arrowX, isLeftToRight: isLeftToRight)
    }

    /// Whether the separator actually took the width it was given. AppKit keeps
    /// the window at its previous size when a system ignores `length`, so a
    /// collapse that reports success while the bar never changed has to be
    /// recognised and undone rather than left as the card's only remark.
    static func separatorDidWiden(requestedLength: CGFloat, windowWidth: CGFloat?) -> Bool {
        guard let windowWidth, windowWidth.isFinite else { return false }
        guard requestedLength.isFinite, requestedLength > expandedSeparatorLength else { return false }
        return windowWidth >= requestedLength / 2
    }

    private static func usableWidth(_ widestScreenWidth: CGFloat?) -> CGFloat {
        guard let widestScreenWidth,
              widestScreenWidth.isFinite,
              widestScreenWidth > 0 else { return fallbackScreenWidth }
        return widestScreenWidth
    }
}

/// The countdown that puts the bar back after the user stopped looking at it.
enum MenuBarHidingAutoCollapse {
    /// Long enough to read a reading or click a submenu, short enough that a
    /// forgotten expansion does not last.
    static let defaultSeconds: Double = 10
    static let minimumSeconds: Double = 3
    static let maximumSeconds: Double = 90

    /// A saved value outside the allowed range (an older build, a hand-edited
    /// preference file) is clamped instead of discarded: the user's intent is
    /// visible in the number even when the number is not allowed.
    static func sanitizedSeconds(_ raw: Double) -> Double {
        guard raw.isFinite else { return defaultSeconds }
        return min(max(raw.rounded(), minimumSeconds), maximumSeconds)
    }

    /// Expanding is what arms the countdown. A collapse the user asked for must
    /// not be undone by a timer.
    static func shouldArmTimer(enabled: Bool, collapsed: Bool) -> Bool {
        enabled && !collapsed
    }

    /// Collapsing is deferred while the pointer is inside the menu bar (the
    /// user is hovering or dragging an icon) or while one of our own windows is
    /// in front (Settings is being edited). Deferral re-arms the timer; it
    /// never queues a collapse to fire later.
    static func shouldWait(pointerInMenuBar: Bool, appWindowInFront: Bool) -> Bool {
        pointerInMenuBar || appWindowInFront
    }
}

/// A screen's two frames, kept apart from `NSScreen` so the menu bar band can
/// be computed in a test.
struct MenuBarHidingScreen: Equatable {
    /// The whole display.
    let frame: CGRect
    /// The part macOS leaves to apps; the menu bar occupies the band above it.
    let visibleFrame: CGRect
}

enum MenuBarHidingHover {
    /// A pointer that merely passes through the bar must not unroll it, so it
    /// has to rest inside the band for this long first.
    static let dwellSeconds: TimeInterval = 0.5

    /// Whether the pointer is in the menu bar band of any display, which is the
    /// strip between `visibleFrame.maxY` and `frame.maxY`. On a fullscreen
    /// Space the bar is gone and the band collapses to nearly nothing, so this
    /// is false there: no visible bar means nothing to expand into view.
    static func isPointerInMenuBar(pointer: CGPoint, screens: [MenuBarHidingScreen]) -> Bool {
        guard pointer.x.isFinite, pointer.y.isFinite else { return false }
        return screens.contains { screen in
            let bandHeight = screen.frame.maxY - screen.visibleFrame.maxY
            guard bandHeight > 1 else { return false }
            return pointer.x >= screen.frame.minX && pointer.x <= screen.frame.maxX
                && pointer.y >= screen.visibleFrame.maxY && pointer.y <= screen.frame.maxY
        }
    }
}

/// Which half of the two-section model a status item falls into, read from where
/// the user `⌘`-dragged it relative to the separator. Mirrors the menu bar's own
/// left-to-right or mirrored arrangement.
enum MenuBarHidingSection: Equatable {
    case hidden
    case visible

    static func section(ofItemX itemX: CGFloat?,
                        separatorX: CGFloat?,
                        isLeftToRight: Bool) -> MenuBarHidingSection {
        MenuBarHidingLayout.isOnHiddenSide(itemX, of: separatorX, isLeftToRight: isLeftToRight)
            ? .hidden
            : .visible
    }
}
