//
//  SettingsView.swift
//  Counts
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    let onDone: () -> Void

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.themeMode) {
                        ForEach(AppSettings.ThemeMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Accent color", selection: $settings.accentColorName) {
                        ForEach(AppSettings.AccentColorName.allCases) { colorName in
                            HStack {
                                Circle()
                                    .fill(colorName.color)
                                    .frame(width: 10, height: 10)
                                Text(colorName.title)
                            }
                            .tag(colorName)
                        }
                    }
                }

                Section("Task Behavior") {
                    Stepper(
                        "Default frequency: \(settings.defaultFrequencyPerDay) / day",
                        value: $settings.defaultFrequencyPerDay,
                        in: 1...999
                    )
                }

                Section("Day & Progress") {
                    DatePicker(
                        "Day starts at",
                        selection: $settings.dayStartDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    Toggle("Auto reset", isOn: $settings.autoResetEnabled)

                    Picker("Show progress as", selection: $settings.progressDisplayMode) {
                        ForEach(AppSettings.ProgressDisplayMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notifications") {
                    mockFeatureRow(
                        title: "Coming Soon",
                        subtitle: "Notification controls will appear here in a future update.",
                        systemImage: "bell.badge"
                    )
                }

                Section("Data") {
                    mockFeatureRow(
                        title: "Coming Soon",
                        subtitle: "Backup, export, and sync options will appear here in a future update.",
                        systemImage: "externaldrive"
                    )
                }

                Section("About") {
                    LabeledContent("Version", value: appVersionText)
                    Text("Counts keeps your task data on this device. No account required.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Link("Send feedback", destination: URL(string: "https://example.com/feedback")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
    }

    private func mockFeatureRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .frame(width: 22)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

