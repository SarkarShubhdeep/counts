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
    
    var modelContainer: ModelContainer = {
        let schema = Schema([TaskEntity.self, DailyRecordEntity.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(settings.themeMode.colorScheme)
                .tint(settings.accentColorName.color)
        }
        .modelContainer(modelContainer)
    }
}
