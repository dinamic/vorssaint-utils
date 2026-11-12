// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Combine
import Foundation
import os

/// Owns the menu bar items that collapse a section of the bar, the way Hidden
/// Bar does: an arrow to click and a hairline separator to `⌘`-drag between the
/// icons that should stay and the icons that should go. Inflating the separator
/// pushes the far side off the bar; shrinking it brings the icons back.
///
/// The service owns the items, the presses and the timers; how the bar is
/// actually made to move is the engine's business (see `MenuBarHidingEngine`).
///
/// Nothing exists until the feature is switched on: with the preference off,
/// this type holds no status items, no timer and no event monitor.
final class MenuBarHidingService: ObservableObject, MenuBarHidingItemProvider {
    static let shared = MenuBarHidingService()

    /// The engine's live state, published so the Settings card can explain a
    /// fail-open instead of leaving the switch looking broken. Only the engine
    /// decides it; the service just mirrors it on every refresh.
    @Published private(set) var state: MenuBarHidingState = .expanded

    /// Which mechanism the installed engine uses. The Settings card branches on
    /// it: the width engine is placed with a draggable separator, the macOS 27
    /// assessment engine conceals whole apps and has no separator at all.
    @Published private(set) var mechanism: MenuBarHidingMechanism = .width

    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "vorssaint",
                                    category: "menu-bar-hiding")

    private static let toggleAutosaveName = "VorssaintMenuBarHidingArrow"
    private static let separatorAutosaveName = "VorssaintMenuBarHidingSeparator"
    private static let alwaysHiddenAutosaveName = "VorssaintMenuBarHidingAlwaysHidden"

    private(set) var toggleItem: NSStatusItem?
    private(set) var separatorItem: NSStatusItem?
    private(set) var alwaysHiddenItem: NSStatusItem?

    private var engine: MenuBarHidingEngine?
    private var autoCollapseTimer: Timer?
    private var hoverGlobalMonitor: Any?
    private var hoverLocalMonitor: Any?
    private var hoverDwellTimer: Timer?
    private var defaultsObserver: NSObjectProtocol?
    private var screenObserver: NSObjectProtocol?

    /// The preferences the live items were built from. A defaults notification
    /// that changes nothing this feature reads must not touch the menu bar.
    private var appliedConfiguration: Configuration?

    /// Rapid double clicks would otherwise collapse and expand faster than the
    /// bar can settle, which leaves items stacked in the Dock or half drawn.
    private var isToggling = false

    private var strings: MenuBarHidingStrings {
        FeatureStrings.menuBarHiding(L10n.shared.language)
    }

    private init() {}

    /// Kept for the lifetime of the app: called once at launch, from the
    /// delegate. Everything after that arrives through preference changes.
    func start() {
        guard defaultsObserver == nil else { return }
        // The card has to describe the right model before the feature is even
        // switched on, so the mechanism is chosen here as well as at install.
        mechanism = MenuBarHidingAssessment.mechanism(
            osMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            classesLoaded: MenuBarHidingAssessmentRuntime.shared.isAvailable
        )
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncWithPreferences()
        }
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // A display hot-plug changes the width a collapse has to cover.
            self?.engine?.invalidateLayout()
        }
        syncWithPreferences()
    }

    /// Reconciles the menu bar with the saved preferences. Idempotent, and
    /// cheap when nothing changed, because `UserDefaults` announces every write
    /// in the app, not only the ones this feature cares about.
    func syncWithPreferences() {
        let configuration = Configuration()
        guard configuration.enabled else {
            if appliedConfiguration?.enabled == true { stop() }
            appliedConfiguration = configuration
            return
        }

        // `UserDefaults` announces every write in the app, so a preference this
        // feature does not read must stop here, before anything touches the bar.
        let installsItems = toggleItem == nil
        let previous = appliedConfiguration
        guard installsItems || previous != configuration else { return }
        appliedConfiguration = configuration

        if installsItems { installItems() }
        // The always hidden separator has to exist before the engine can size
        // it, so the item comes first.
        syncAlwaysHiddenItem(enabled: configuration.alwaysHiddenSection)
        engine?.updateAlwaysHiddenSection(enabled: configuration.alwaysHiddenSection,
                                          hidingSection: configuration.hideSeparators)
        engine?.updateHiddenBundleIDs(configuration.hiddenBundleIDs)
        syncHoverMonitor(enabled: configuration.hoverToExpand)
        refreshToggleImage()

        if installsItems {
            // The item has no window yet on this tick, and the arrangement can
            // only be judged from a placed window. Give AppKit a moment.
            if configuration.startCollapsed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.collapse()
                }
            }
        } else if configuration.startCollapsed, previous?.startCollapsed != true {
            // Switching the option on while the feature is already running has
            // to show what it does, otherwise the toggle looks inert.
            collapse()
        } else {
            syncAutoCollapseTimer(collapsed: state == .collapsed)
        }
    }

    /// The press every one of our items shares: plain click toggles, right
    /// click opens the menu, option toggles the always hidden section.
    func handlePress(from button: NSStatusBarButton) {
        let event = NSApp.currentEvent
        let action = MenuBarHidingActionResolver.action(
            isRightClick: event?.type == .rightMouseUp,
            optionPressed: event?.modifierFlags.contains(.option) ?? false
        )
        switch action {
        case .contextMenu:
            showContextMenu(from: button)
        case .toggleSections:
            toggleAlwaysHiddenSection()
        case .toggle:
            toggle()
        }
    }

    func toggle() {
        guard !isToggling else { return }
        isToggling = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isToggling = false
        }
        if engine?.state == .collapsed {
            expand()
        } else {
            collapse()
        }
    }

    func collapse() {
        guard let engine, engine.state != .collapsed else { return }
        engine.collapse { [weak self] _ in
            guard let self else { return }
            self.refreshToggleImage()
            // Either the bar is collapsed or the engine refused to collapse it;
            // both mean a countdown here has nothing left to do.
            self.cancelAutoCollapseTimer()
        }
    }

    func expand() {
        guard let engine, engine.state != .expanded else { return }
        engine.expand()
        refreshToggleImage()
        syncAutoCollapseTimer(collapsed: false)
    }

    // MARK: - Items

    private func installItems() {
        // A fresh item starts blank, so every width and image is applied below
        // rather than inherited from a previous install.
        let toggle = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        toggle.autosaveName = Self.toggleAutosaveName
        // Empty behaviors keep the item in the bar: `⌘`-dragging may move it,
        // which is how the user decides what gets hidden, but never removes it,
        // which would leave the feature unreachable.
        toggle.behavior = []
        toggle.isVisible = true
        if let button = toggle.button {
            button.image = Self.chevronImage(collapsed: false, isLeftToRight: isLeftToRight)
            button.target = self
            button.action = #selector(itemPressed(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let separator = NSStatusBar.system.statusItem(withLength: MenuBarHidingLayout.expandedSeparatorLength)
        separator.autosaveName = Self.separatorAutosaveName
        separator.behavior = []
        separator.isVisible = true
        if let button = separator.button {
            button.image = Self.separatorImage()
            button.target = self
            button.action = #selector(itemPressed(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            // This separator is the only handle the whole placement flow
            // depends on, so it cannot be an unlabeled button to VoiceOver.
            button.toolTip = strings.separatorAccessibilityLabel
            button.setAccessibilityLabel(strings.separatorAccessibilityLabel)
        }

        toggleItem = toggle
        let log: (String) -> Void = { message in
            Self.log.debug("\(message, privacy: .public)")
        }
        let mechanism = MenuBarHidingAssessment.mechanism(
            osMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            classesLoaded: MenuBarHidingAssessmentRuntime.shared.isAvailable
        )
        self.mechanism = mechanism
        let engine: MenuBarHidingEngine
        switch mechanism {
        case .assessment:
            // macOS 27 conceals whole apps; there is no boundary to place, so
            // the separator would be a control that does nothing. The chevron
            // stays as the toggle.
            NSStatusBar.system.removeStatusItem(separator)
            separatorItem = nil
            engine = AssessmentMenuBarHidingEngine(
                items: self,
                hiddenBundleIDs: Configuration().hiddenBundleIDs,
                log: log
            )
        case .width:
            separatorItem = separator
            engine = LengthMenuBarHidingEngine(items: self, log: log)
        }
        // A fail-open happens after the engine already reported a collapse, so
        // the arrow and the Settings card have to hear about it from here.
        engine.stateDidChange = { [weak self] in
            self?.refreshToggleImage()
        }
        self.engine = engine
        refreshToggleImage()
        Self.log.debug("menu bar items installed with the \(mechanism == .assessment ? "assessment" : "width") engine")
    }

    private func syncAlwaysHiddenItem(enabled: Bool) {
        // The always hidden section is a second positional boundary, which only
        // the width engine has. On macOS 27 the item would be inert.
        guard mechanism == .width else {
            if let item = alwaysHiddenItem {
                NSStatusBar.system.removeStatusItem(item)
                alwaysHiddenItem = nil
            }
            return
        }
        if enabled {
            guard alwaysHiddenItem == nil else { return }
            let item = NSStatusBar.system.statusItem(withLength: 0)
            item.autosaveName = Self.alwaysHiddenAutosaveName
            item.behavior = []
            item.isVisible = true
            if let button = item.button {
                button.image = Self.separatorImage()
                // Dimmed: this one marks a section that is meant to stay out of
                // the way, so it must not read as a live control.
                button.appearsDisabled = true
                button.target = self
                button.action = #selector(itemPressed(_:))
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
                button.setAccessibilityLabel(strings.alwaysHiddenAccessibilityLabel)
            }
            alwaysHiddenItem = item
        } else if let item = alwaysHiddenItem {
            NSStatusBar.system.removeStatusItem(item)
            alwaysHiddenItem = nil
        }
    }

    private func stop() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil
        hoverDwellTimer?.invalidate()
        hoverDwellTimer = nil
        syncHoverMonitor(enabled: false)
        for item in [alwaysHiddenItem, separatorItem, toggleItem] {
            if let item { NSStatusBar.system.removeStatusItem(item) }
        }
        alwaysHiddenItem = nil
        separatorItem = nil
        toggleItem = nil
        engine?.stop()
        engine = nil
        state = .expanded
        // macOS keeps a removed item's saved position and visibility under its
        // autosave name. Left behind, the next install would come back at an
        // old spot with an old collapsed width.
        Self.clearRememberedState()
        Self.log.debug("menu bar items removed")
    }

    private static func clearRememberedState() {
        let defaults = UserDefaults.standard
        for name in [toggleAutosaveName, separatorAutosaveName, alwaysHiddenAutosaveName] {
            defaults.removeObject(forKey: "NSStatusItem Visible \(name)")
            defaults.removeObject(forKey: "NSStatusItem VisibleCC \(name)")
            defaults.removeObject(forKey: "NSStatusItem Preferred Position \(name)")
        }
    }

    // MARK: - Presses and menu

    @objc private func itemPressed(_ sender: NSStatusBarButton) {
        handlePress(from: sender)
    }

    /// The menu is built fresh for every presentation, so each line reflects the
    /// state at the moment it is opened instead of a stale title patched later.
    private func showContextMenu(from button: NSStatusBarButton) {
        let strings = self.strings
        let menu = NSMenu()
        // A mechanism this macOS ignores has to be said out loud: the two
        // commands below cannot work, and a menu that silently does nothing is
        // exactly the broken look the fail-open state exists to avoid.
        let unavailable = state == .unavailable

        let expandItem = menuItem(title: strings.menuExpand, action: #selector(expandFromMenu))
        expandItem.isEnabled = !unavailable
        menu.addItem(expandItem)
        let collapseItem = menuItem(title: strings.menuCollapse, action: #selector(collapseFromMenu))
        collapseItem.isEnabled = !unavailable
        menu.addItem(collapseItem)
        if unavailable {
            let notice = NSMenuItem(title: strings.unavailableTitle, action: nil, keyEquivalent: "")
            notice.isEnabled = false
            menu.addItem(notice)
        }
        menu.addItem(.separator())

        let defaults = UserDefaults.standard
        let autoCollapse = defaults.bool(forKey: DefaultsKey.menuBarHidingAutoCollapse)
        menu.addItem(menuItem(title: autoCollapse ? strings.menuDisableAutoCollapse
                                                  : strings.menuEnableAutoCollapse,
                              action: #selector(toggleAutoCollapseFromMenu)))

        if defaults.bool(forKey: DefaultsKey.menuBarHidingAlwaysHiddenSection) {
            let hideSeparators = defaults.bool(forKey: DefaultsKey.menuBarHidingHideSeparators)
            menu.addItem(menuItem(title: hideSeparators ? strings.menuShowSections
                                                        : strings.menuHideSections,
                                  action: #selector(toggleAlwaysHiddenSectionFromMenu)))
        }

        menu.addItem(.separator())
        menu.addItem(menuItem(title: strings.menuSettings, action: #selector(openSettings)))
        menu.addItem(menuItem(title: strings.menuTurnOff, action: #selector(turnOff)))
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: button)
    }

    private func menuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func expandFromMenu() {
        expand()
    }

    @objc private func collapseFromMenu() {
        collapse()
    }

    @objc private func toggleAutoCollapseFromMenu() {
        let defaults = UserDefaults.standard
        defaults.set(!defaults.bool(forKey: DefaultsKey.menuBarHidingAutoCollapse),
                     forKey: DefaultsKey.menuBarHidingAutoCollapse)
    }

    @objc private func toggleAlwaysHiddenSectionFromMenu() {
        toggleAlwaysHiddenSection()
    }

    @objc private func openSettings() {
        SettingsRouter.shared.request(FeatureSettingsDestination(.general, sectionAnchor: .menuBarHiding))
        (NSApp.delegate as? AppDelegate)?.openSettingsWindow()
    }

    @objc private func turnOff() {
        UserDefaults.standard.set(false, forKey: DefaultsKey.menuBarHidingEnabled)
    }

    private func toggleAlwaysHiddenSection() {
        let defaults = UserDefaults.standard
        defaults.set(!defaults.bool(forKey: DefaultsKey.menuBarHidingHideSeparators),
                     forKey: DefaultsKey.menuBarHidingHideSeparators)
        // Revealing a section the user cannot see is the point of the press, so
        // expand the bar when the press came while it was collapsed.
        if engine?.state == .collapsed { expand() }
    }

    // MARK: - Countdown

    private func syncAutoCollapseTimer(collapsed: Bool) {
        let configuration = Configuration()
        guard MenuBarHidingAutoCollapse.shouldArmTimer(enabled: configuration.autoCollapse,
                                                       collapsed: collapsed) else {
            cancelAutoCollapseTimer()
            return
        }
        startAutoCollapseTimer(seconds: configuration.autoCollapseSeconds)
    }

    private func cancelAutoCollapseTimer() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil
    }

    private func startAutoCollapseTimer(seconds: Double) {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.autoCollapseTimer = nil
            guard Configuration().autoCollapse else { return }
            // Never yank the bar shut mid-interaction. The wait re-arms rather
            // than queues, so a pointer resting in the bar cannot pile up a
            // backlog of collapses.
            // `isActive` alone is app-wide: an accessory app can be "active"
            // with no window in front. Requiring a key window matches the
            // intent, which is "Settings is open and being edited".
            let windowInFront = NSApp.isActive && NSApp.keyWindow != nil
            if MenuBarHidingAutoCollapse.shouldWait(pointerInMenuBar: self.isPointerInMenuBar,
                                                    appWindowInFront: windowInFront) {
                self.startAutoCollapseTimer(seconds: Configuration().autoCollapseSeconds)
            } else {
                self.collapse()
            }
        }
    }

    // MARK: - Hover to expand

    private func syncHoverMonitor(enabled: Bool) {
        if enabled {
            guard hoverGlobalMonitor == nil else { return }
            // Mouse events need no accessibility grant, unlike keyboard ones.
            hoverGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
                self?.pointerMoved()
            }
            // Moving over our own status item is delivered locally, not
            // globally, so without this the arrow itself would not respond.
            hoverLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
                self?.pointerMoved()
                return event
            }
        } else {
            if let hoverGlobalMonitor { NSEvent.removeMonitor(hoverGlobalMonitor) }
            if let hoverLocalMonitor { NSEvent.removeMonitor(hoverLocalMonitor) }
            hoverGlobalMonitor = nil
            hoverLocalMonitor = nil
            hoverDwellTimer?.invalidate()
            hoverDwellTimer = nil
        }
    }

    private func pointerMoved() {
        guard engine?.state == .collapsed, isPointerInMenuBar else {
            hoverDwellTimer?.invalidate()
            hoverDwellTimer = nil
            return
        }
        // One dwell at a time: a pointer passing through the bar keeps arriving
        // as movement, and every arrival would otherwise restart the wait.
        guard hoverDwellTimer == nil else { return }
        hoverDwellTimer = Timer.scheduledTimer(withTimeInterval: MenuBarHidingHover.dwellSeconds,
                                               repeats: false) { [weak self] _ in
            guard let self else { return }
            self.hoverDwellTimer = nil
            if self.engine?.state == .collapsed, self.isPointerInMenuBar {
                self.expand()
            }
        }
    }

    // MARK: - Appearance

    private var isLeftToRight: Bool {
        NSApplication.shared.userInterfaceLayoutDirection == .leftToRight
    }

    private var isPointerInMenuBar: Bool {
        MenuBarHidingHover.isPointerInMenuBar(
            pointer: NSEvent.mouseLocation,
            screens: NSScreen.screens.map {
                MenuBarHidingScreen(frame: $0.frame, visibleFrame: $0.visibleFrame)
            }
        )
    }

    private func refreshToggleImage() {
        let current = engine?.state ?? .expanded
        // Published so the Settings card can explain a fail-open. Assigned only
        // on change: `objectWillChange` on every pass would redraw the card.
        if state != current { state = current }
        guard let button = toggleItem?.button else { return }
        let strings = self.strings
        guard current != .unavailable else {
            button.image = Self.chevronImage(collapsed: false, isLeftToRight: isLeftToRight)
            button.toolTip = strings.unavailableTitle
            button.setAccessibilityLabel(strings.unavailableTitle)
            return
        }
        let collapsed = current == .collapsed
        button.image = Self.chevronImage(collapsed: collapsed, isLeftToRight: isLeftToRight)
        button.toolTip = collapsed ? strings.expandTooltip : strings.collapseTooltip
        button.setAccessibilityLabel(collapsed ? strings.expandAccessibilityLabel
                                               : strings.collapseAccessibilityLabel)
    }

    /// The arrow points at the icons it acts on: toward the hidden side while
    /// expanded, back toward the bar once they are hidden. Mirrored in a
    /// right-to-left interface, where the hidden side is the other one.
    private static func chevronImage(collapsed: Bool, isLeftToRight: Bool) -> NSImage? {
        let pointsLeft = isLeftToRight ? !collapsed : collapsed
        let image = NSImage(systemSymbolName: pointsLeft ? "chevron.left" : "chevron.right",
                            accessibilityDescription: nil)
        image?.isTemplate = true
        return image
    }

    private static func separatorImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 1, height: 16), flipped: false) { rect in
            NSColor.tertiaryLabelColor.setFill()
            NSBezierPath(rect: rect.insetBy(dx: 0, dy: 1)).fill()
            return true
        }
        image.isTemplate = true
        return image
    }

    // MARK: - Preferences

    /// Everything this feature reads, in one comparable value, so a defaults
    /// notification is a no-op unless one of these actually moved.
    private struct Configuration: Equatable {
        let enabled: Bool
        let autoCollapse: Bool
        let autoCollapseSeconds: Double
        let hoverToExpand: Bool
        let hideSeparators: Bool
        let alwaysHiddenSection: Bool
        let startCollapsed: Bool
        /// The apps the macOS 27 assessment engine conceals. Empty on the width
        /// engine, which hides by position instead.
        let hiddenBundleIDs: Set<String>

        init(defaults: UserDefaults = .standard) {
            enabled = defaults.bool(forKey: DefaultsKey.menuBarHidingEnabled)
            autoCollapse = defaults.bool(forKey: DefaultsKey.menuBarHidingAutoCollapse)
            autoCollapseSeconds = MenuBarHidingAutoCollapse.sanitizedSeconds(
                defaults.double(forKey: DefaultsKey.menuBarHidingAutoCollapseSeconds)
            )
            hoverToExpand = defaults.bool(forKey: DefaultsKey.menuBarHidingHoverToExpand)
            hideSeparators = defaults.bool(forKey: DefaultsKey.menuBarHidingHideSeparators)
            alwaysHiddenSection = defaults.bool(forKey: DefaultsKey.menuBarHidingAlwaysHiddenSection)
            startCollapsed = defaults.bool(forKey: DefaultsKey.menuBarHidingStartCollapsed)
            hiddenBundleIDs = Set(defaults.stringArray(forKey: DefaultsKey.menuBarHidingHiddenBundleIDs) ?? [])
        }
    }
}
