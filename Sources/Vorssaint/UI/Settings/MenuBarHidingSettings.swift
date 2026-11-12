// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import SwiftUI

/// The "Menu bar hiding" card under Settings → General → Menu bar: the switch
/// that installs the arrow and separator, and the handful of behaviors that
/// make them usable.
///
/// The card has two shapes because the mechanism depends on the running macOS.
/// Up to macOS 26 the bar reflows around an inflated separator, so the user
/// places a boundary with `⌘`-drag. On macOS 27 that no longer works and the
/// engine conceals whole apps through the assessment-mode facility instead:
/// there is no separator to drag and no section boundary, so the card shows an
/// app picker and says so rather than silently changing what the arrow means.
///
/// Everything below the switch stays hidden while the feature is off, so the
/// card reads as one decision with its consequences rather than a wall of
/// options for a feature nobody turned on.
struct MenuBarHidingSettings: View {
    @ObservedObject private var l10n = L10n.shared
    /// The live engine state: a collapse this macOS refuses has to be explained
    /// here, otherwise the switch above it reads as broken.
    @ObservedObject private var hiding = MenuBarHidingService.shared

    @AppStorage(DefaultsKey.menuBarHidingEnabled) private var enabled = false
    @AppStorage(DefaultsKey.menuBarHidingStartCollapsed) private var startCollapsed = false
    @AppStorage(DefaultsKey.menuBarHidingAutoCollapse) private var autoCollapse = false
    @AppStorage(DefaultsKey.menuBarHidingAutoCollapseSeconds)
    private var autoCollapseSeconds = MenuBarHidingAutoCollapse.defaultSeconds
    @AppStorage(DefaultsKey.menuBarHidingHoverToExpand) private var hoverToExpand = false
    @AppStorage(DefaultsKey.menuBarHidingAlwaysHiddenSection) private var alwaysHiddenSection = false
    @AppStorage(DefaultsKey.menuBarHidingHideSeparators) private var hideSeparators = false

    /// `@AppStorage` has no array form, so the selection is read and written
    /// through `UserDefaults` directly. Every write posts the defaults
    /// notification the service already listens to.
    @State private var hiddenBundleIDs: [String] = []
    @State private var runningApps: [NSRunningApplication] = []

    private var strings: MenuBarHidingStrings {
        FeatureStrings.menuBarHiding(l10n.language)
    }

    private var secondsRange: ClosedRange<Double> {
        MenuBarHidingAutoCollapse.minimumSeconds...MenuBarHidingAutoCollapse.maximumSeconds
    }

    private var isAssessment: Bool {
        hiding.mechanism == .assessment
    }

    /// Apps the user can choose from: anything running that has a bundle
    /// identifier and can own a menu bar item. Vorssaint itself is left out so
    /// hiding it cannot take the arrow away.
    private var selectableApps: [NSRunningApplication] {
        let ownBundleID = Bundle.main.bundleIdentifier
        return runningApps
            .filter { app in
                guard let id = app.bundleIdentifier else { return false }
                return id != ownBundleID && app.activationPolicy != .prohibited
            }
            .sorted {
                ($0.localizedName ?? $0.bundleIdentifier ?? "")
                    < ($1.localizedName ?? $1.bundleIdentifier ?? "")
            }
    }

    private var isOutsideApplications: Bool {
        !Bundle.main.bundlePath.hasPrefix("/Applications/")
    }

    var body: some View {
        SettingsCard(title: strings.section) {
            SettingsRow(symbol: "chevron.left",
                        title: strings.enableToggle,
                        caption: isAssessment ? strings.assessmentCaption : strings.placementHint) {
                Toggle(strings.enableToggle, isOn: $enabled)
                    .labelsHidden()
            }

            if enabled {
                Divider()

                if hiding.state == .unavailable {
                    SettingsRow(symbol: "exclamationmark.triangle",
                                title: strings.unavailableTitle,
                                caption: isAssessment ? strings.assessmentUnavailableCaption
                                                      : strings.unavailableCaption) {
                        EmptyView()
                    }
                }

                if isAssessment {
                    if isOutsideApplications {
                        SettingsRow(symbol: "folder.badge.questionmark",
                                    title: strings.applicationsFolderCaption,
                                    caption: nil) {
                            EmptyView()
                        }
                    }
                    assessmentAppPicker
                }

                SettingsRow(symbol: "chevron.down",
                            title: strings.startCollapsedToggle,
                            caption: strings.startCollapsedCaption) {
                    Toggle(strings.startCollapsedToggle, isOn: $startCollapsed)
                        .labelsHidden()
                }

                SettingsRow(symbol: "timer",
                            title: strings.autoCollapseToggle,
                            caption: strings.autoCollapseCaption) {
                    Toggle(strings.autoCollapseToggle, isOn: $autoCollapse)
                        .labelsHidden()
                }

                if autoCollapse {
                    SettingsRow(symbol: "hourglass", title: strings.autoCollapseSeconds) {
                        Stepper(value: $autoCollapseSeconds, in: secondsRange, step: 1) {
                            Text(verbatim: "\(Int(autoCollapseSeconds)) s")
                        }
                        .fixedSize()
                    }
                }

                SettingsRow(symbol: "cursorarrow.motionlines", title: strings.hoverToggle) {
                    Toggle(strings.hoverToggle, isOn: $hoverToExpand)
                        .labelsHidden()
                }

                // The always hidden section is a positional concept: it only
                // exists where the width engine can place a second separator.
                if !isAssessment {
                    SettingsRow(symbol: "rectangle.split.3x1",
                                title: strings.alwaysHiddenToggle,
                                caption: strings.alwaysHiddenCaption) {
                        Toggle(strings.alwaysHiddenToggle, isOn: $alwaysHiddenSection)
                            .labelsHidden()
                    }

                    if alwaysHiddenSection {
                        SettingsRow(symbol: "eye.slash", title: strings.menuHideSections) {
                            Toggle(strings.menuHideSections, isOn: $hideSeparators)
                                .labelsHidden()
                        }
                    }
                }
            }
        }
        .onAppear(perform: refreshRunningApps)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshRunningApps()
        }
    }

    /// The macOS 27 selection surface: concealment is per app, so the user picks
    /// apps rather than dragging a boundary. The list is a snapshot of what is
    /// running; the engine keeps the allowlist current as apps launch.
    private var assessmentAppPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsRow(symbol: "app.badge.checkmark",
                        title: strings.appPickerTitle,
                        caption: strings.appPickerCaption) {
                Button {
                    refreshRunningApps()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help(strings.appPickerTitle)
            }

            ForEach(selectableApps, id: \.bundleIdentifier) { app in
                if let id = app.bundleIdentifier {
                    AppSelectionRow(name: app.localizedName ?? id,
                                    isHidden: binding(for: id))
                }
            }
        }
    }

    private func binding(for bundleID: String) -> Binding<Bool> {
        Binding(
            get: { hiddenBundleIDs.contains(bundleID) },
            set: { hidden in
                var ids = Set(hiddenBundleIDs)
                if hidden {
                    ids.insert(bundleID)
                } else {
                    ids.remove(bundleID)
                }
                let sorted = ids.sorted()
                hiddenBundleIDs = sorted
                UserDefaults.standard.set(sorted, forKey: DefaultsKey.menuBarHidingHiddenBundleIDs)
            }
        )
    }

    private func refreshRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
        hiddenBundleIDs = UserDefaults.standard
            .stringArray(forKey: DefaultsKey.menuBarHidingHiddenBundleIDs) ?? []
    }
}

/// One app in the macOS 27 picker. Deliberately not a `SettingsRow`: its title
/// is an app name, not a localized setting label, so Settings search has no
/// entry to point at and the coverage scan must not treat it as one.
private struct AppSelectionRow: View {
    let name: String
    @Binding var isHidden: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app")
                .frame(width: 18)
                .foregroundStyle(.secondary)
            Text(name)
            Spacer(minLength: 12)
            Toggle(name, isOn: $isHidden)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
