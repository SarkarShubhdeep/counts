//
//  AppSettings.swift
//  Counts
//

import Combine
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    enum ThemeMode: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: String { rawValue }

        var title: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    enum AccentColorName: String, CaseIterable, Identifiable {
        case blue
        case green
        case orange
        case purple
        case pink

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }

        var color: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .purple: return .purple
            case .pink: return .pink
            }
        }
    }

    enum ProgressDisplayMode: String, CaseIterable, Identifiable {
        case fraction
        case percent

        var id: String { rawValue }

        var title: String {
            switch self {
            case .fraction: return "Fraction"
            case .percent: return "Percent"
            }
        }
    }

    private enum Key {
        static let themeMode = "settings.themeMode"
        static let accentColorName = "settings.accentColorName"
        static let defaultFrequencyPerDay = "settings.defaultFrequencyPerDay"
        static let dayStartMinutes = "settings.dayStartMinutes"
        static let autoResetEnabled = "settings.autoResetEnabled"
        static let progressDisplayMode = "settings.progressDisplayMode"
        static let lastResetLogicalDayID = "settings.lastResetLogicalDayID"
    }

    private let defaults: UserDefaults

    @Published var themeMode: ThemeMode { didSet { defaults.set(themeMode.rawValue, forKey: Key.themeMode) } }
    @Published var accentColorName: AccentColorName { didSet { defaults.set(accentColorName.rawValue, forKey: Key.accentColorName) } }
    @Published var defaultFrequencyPerDay: Int {
        didSet {
            let clamped = max(1, defaultFrequencyPerDay)
            if clamped != defaultFrequencyPerDay {
                defaultFrequencyPerDay = clamped
                return
            }
            defaults.set(clamped, forKey: Key.defaultFrequencyPerDay)
        }
    }
    /// Minutes after midnight in local time.
    @Published var dayStartMinutes: Int {
        didSet {
            let clamped = min(max(0, dayStartMinutes), 23 * 60 + 59)
            if clamped != dayStartMinutes {
                dayStartMinutes = clamped
                return
            }
            defaults.set(clamped, forKey: Key.dayStartMinutes)
        }
    }
    @Published var autoResetEnabled: Bool { didSet { defaults.set(autoResetEnabled, forKey: Key.autoResetEnabled) } }
    @Published var progressDisplayMode: ProgressDisplayMode { didSet { defaults.set(progressDisplayMode.rawValue, forKey: Key.progressDisplayMode) } }
    @Published var lastResetLogicalDayID: String? {
        didSet {
            defaults.set(lastResetLogicalDayID, forKey: Key.lastResetLogicalDayID)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedTheme = defaults.string(forKey: Key.themeMode).flatMap(ThemeMode.init(rawValue:))
        themeMode = storedTheme ?? .system

        let storedAccent = defaults.string(forKey: Key.accentColorName).flatMap(AccentColorName.init(rawValue:))
        accentColorName = storedAccent ?? .blue

        let storedFrequency = defaults.object(forKey: Key.defaultFrequencyPerDay) as? Int
        defaultFrequencyPerDay = max(1, storedFrequency ?? 1)

        let storedDayStart = defaults.object(forKey: Key.dayStartMinutes) as? Int
        dayStartMinutes = min(max(0, storedDayStart ?? 0), 23 * 60 + 59)

        let storedAutoReset = defaults.object(forKey: Key.autoResetEnabled) as? Bool
        autoResetEnabled = storedAutoReset ?? true

        let storedProgressMode = defaults.string(forKey: Key.progressDisplayMode).flatMap(ProgressDisplayMode.init(rawValue:))
        progressDisplayMode = storedProgressMode ?? .fraction

        lastResetLogicalDayID = defaults.string(forKey: Key.lastResetLogicalDayID)
    }

    var dayStartDate: Date {
        get {
            let calendar = Calendar.current
            let hour = dayStartMinutes / 60
            let minute = dayStartMinutes % 60
            return calendar.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        }
        set {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: newValue)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            dayStartMinutes = hour * 60 + minute
        }
    }

    func logicalDayID(for date: Date) -> String {
        let calendar = Calendar.current
        let shifted = calendar.date(byAdding: .minute, value: -dayStartMinutes, to: date) ?? date
        let components = calendar.dateComponents([.year, .month, .day], from: shifted)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
