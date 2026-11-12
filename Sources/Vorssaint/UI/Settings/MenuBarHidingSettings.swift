// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The "Menu bar hiding" card on the Monitor page: the switch that installs the
/// arrow and separator, and the handful of behaviors that make them usable.
///
/// Everything below the switch stays hidden while the feature is off, so the
/// card reads as one decision with its consequences rather than a wall of
/// options for a feature nobody turned on.
struct MenuBarHidingSettings: View {
    @ObservedObject private var l10n = L10n.shared

    @AppStorage(DefaultsKey.menuBarHidingEnabled) private var enabled = false
    @AppStorage(DefaultsKey.menuBarHidingAutoCollapse) private var autoCollapse = false
    @AppStorage(DefaultsKey.menuBarHidingAutoCollapseSeconds)
    private var autoCollapseSeconds = MenuBarHidingAutoCollapse.defaultSeconds
    @AppStorage(DefaultsKey.menuBarHidingHoverToExpand) private var hoverToExpand = false
    @AppStorage(DefaultsKey.menuBarHidingAlwaysHiddenSection) private var alwaysHiddenSection = false
    @AppStorage(DefaultsKey.menuBarHidingHideSeparators) private var hideSeparators = false

    private var strings: MenuBarHidingStrings {
        FeatureStrings.menuBarHiding(l10n.language)
    }

    private var secondsRange: ClosedRange<Double> {
        MenuBarHidingAutoCollapse.minimumSeconds...MenuBarHidingAutoCollapse.maximumSeconds
    }

    var body: some View {
        SettingsCard(title: strings.section) {
            SettingsRow(symbol: "chevron.left",
                        title: strings.enableToggle,
                        caption: strings.placementHint) {
                Toggle(strings.enableToggle, isOn: $enabled)
                    .labelsHidden()
            }

            if enabled {
                Divider()

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
}
