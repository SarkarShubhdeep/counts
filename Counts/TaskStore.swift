//
//  TaskStore.swift
//  Counts
//

import Combine
import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [CountsTask]

    init(tasks: [CountsTask] = TaskStore.mockTasks) {
        self.tasks = tasks
    }

    /// Active tasks in creation order (newest first among equals — insertion order preserved).
    var activeTasks: [CountsTask] {
        tasks.filter { !$0.isArchived }
    }

    /// Archived tasks, sorted by title for browsing.
    var archivedTasks: [CountsTask] {
        tasks.filter(\.isArchived).sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    /// Sample tasks for simulator / UI testing (15 items).
    private static let mockTasks: [CountsTask] = [
        CountsTask(title: "Push-ups", frequencyPerDay: 50, description: "Spread sets across the day.", currentCount: 12),
        CountsTask(title: "Read pages", frequencyPerDay: 20, description: "Any book or article.", currentCount: 7),
        CountsTask(title: "Water glasses", frequencyPerDay: 8, description: "8 oz each.", currentCount: 5),
        CountsTask(title: "Stand breaks", frequencyPerDay: 12, description: "2 minutes each hour.", currentCount: 9),
        CountsTask(title: "Walk minutes", frequencyPerDay: 30, description: "Total active walking.", currentCount: 18),
        CountsTask(title: "Deep work blocks", frequencyPerDay: 4, description: "25-minute pomodoros.", currentCount: 2),
        CountsTask(title: "Stretch sessions", frequencyPerDay: 3, description: "Morning, noon, evening.", currentCount: 1),
        CountsTask(title: "Vitamins", frequencyPerDay: 1, description: "After breakfast.", currentCount: 1),
        CountsTask(title: "Journal lines", frequencyPerDay: 10, description: "Gratitude or reflection.", currentCount: 4),
        CountsTask(title: "Inbox zero passes", frequencyPerDay: 3, description: "Process email batches.", currentCount: 2),
        CountsTask(title: "Language flashcards", frequencyPerDay: 25, description: "Spaced repetition deck.", currentCount: 15),
        CountsTask(title: "Stairs climbed", frequencyPerDay: 10, description: "Actual flights or flights-equivalent.", currentCount: 6),
        CountsTask(title: "Connect with someone", frequencyPerDay: 1, description: "Message or call.", currentCount: 0),
        CountsTask(title: "Tidy surfaces", frequencyPerDay: 2, description: "Quick reset pass.", currentCount: 1),
        CountsTask(title: "Sleep by target", frequencyPerDay: 1, description: "Lights out by 11 pm.", currentCount: 0),
    ]

    func addTask(title: String, frequencyPerDay: Int, description: String, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        let task = CountsTask(title: title, frequencyPerDay: frequencyPerDay, description: description)
        tasks.insert(task, at: 0)
    }

    func adjustCount(taskID: UUID, by delta: Int, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].currentCount = max(0, tasks[index].currentCount + delta)
    }

    func updateTask(id: UUID, title: String, frequencyPerDay: Int, description: String, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks[index].frequencyPerDay = max(1, frequencyPerDay)
        tasks[index].description = description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func archiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = true
    }

    func unarchiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = false
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    func applyAutomaticResetIfNeeded(settings: AppSettings?, now: Date = Date()) {
        guard let settings else { return }

        let logicalDay = settings.logicalDayID(for: now)
        defer { settings.lastResetLogicalDayID = logicalDay }

        guard settings.autoResetEnabled else { return }
        guard let lastResetLogicalDayID = settings.lastResetLogicalDayID else { return }
        guard lastResetLogicalDayID != logicalDay else { return }

        for index in tasks.indices where !tasks[index].isArchived {
            tasks[index].currentCount = 0
        }
    }
}
