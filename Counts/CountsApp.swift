//
//  CountsApp.swift
//  Counts
//
//  Created by Shubhdeep Sarkar on 5/4/26.
//

import SwiftUI
import SwiftData

@main
struct CountsApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.themeMode.colorScheme)
                .tint(settings.accentColorName.color)
        }
        .modelContainer(for: [TaskEntity.self])
    }
}
