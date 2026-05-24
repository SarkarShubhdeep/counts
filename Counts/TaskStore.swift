//
//  TaskStore.swift
//  Counts
//

import Combine
import Foundation
import SwiftData

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [CountsTask]
    @Published private(set) var lastErrorMessage: String?

    private var repository: TaskRepository?

    init(tasks: [CountsTask] = []) {
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

    func configurePersistence(modelContext: ModelContext) {
        guard repository == nil else { return }
        repository = SwiftDataTaskRepository(modelContext: modelContext)
        reloadFromRepository()
    }

    func addTask(title: String, frequencyPerDay: Int, description: String, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        if let repository {
            do {
                try repository.addTask(title: title, frequencyPerDay: frequencyPerDay, description: description)
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }

        let task = CountsTask(title: title, frequencyPerDay: frequencyPerDay, description: description)
        tasks.insert(task, at: 0)
    }

    func adjustCount(taskID: UUID, by delta: Int, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        if let repository {
            do {
                try repository.adjustCount(taskID: taskID, by: delta)
                reloadFromRepository()
                updateDailyRecordIfNeeded(taskID: taskID)
            } catch {
                recordError(error)
            }
            return
        }

        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].currentCount = max(0, tasks[index].currentCount + delta)
    }
    
    func fetchDailyRecords(taskID: UUID, lastDays: Int = 100) -> [Date: (count: Int, goal: Int)] {
        guard let repository else { return [:] }
        do {
            return try repository.fetchDailyRecords(taskID: taskID, lastDays: lastDays)
        } catch {
            recordError(error)
            return [:]
        }
    }
    
    private func updateDailyRecordIfNeeded(taskID: UUID) {
        guard let repository else { return }
        guard let task = tasks.first(where: { $0.id == taskID }) else { return }
        
        do {
            try repository.recordDailyProgress(
                taskID: taskID,
                count: task.currentCount,
                goal: task.frequencyPerDay,
                date: Date()
            )
        } catch {
            recordError(error)
        }
    }

    func updateTask(id: UUID, title: String, frequencyPerDay: Int, description: String, settings: AppSettings? = nil) {
        applyAutomaticResetIfNeeded(settings: settings)
        if let repository {
            do {
                try repository.updateTask(
                    id: id,
                    title: title,
                    frequencyPerDay: frequencyPerDay,
                    description: description
                )
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }

        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks[index].frequencyPerDay = max(1, frequencyPerDay)
        tasks[index].description = description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func archiveTask(id: UUID) {
        if let repository {
            do {
                try repository.setArchived(taskID: id, isArchived: true)
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = true
    }

    func unarchiveTask(id: UUID) {
        if let repository {
            do {
                try repository.setArchived(taskID: id, isArchived: false)
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = false
    }

    func deleteTask(id: UUID) {
        if let repository {
            do {
                try repository.deleteTask(taskID: id)
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }
        tasks.removeAll { $0.id == id }
    }

    func applyAutomaticResetIfNeeded(settings: AppSettings?, now: Date = Date()) {
        guard let settings else { return }

        let logicalDay = settings.logicalDayID(for: now)
        defer { settings.lastResetLogicalDayID = logicalDay }

        guard settings.autoResetEnabled else { return }
        guard let lastResetLogicalDayID = settings.lastResetLogicalDayID else { return }
        guard lastResetLogicalDayID != logicalDay else { return }

        if let repository {
            do {
                try repository.resetCountsForActiveTasks()
                reloadFromRepository()
            } catch {
                recordError(error)
            }
            return
        }

        for index in tasks.indices where !tasks[index].isArchived {
            tasks[index].currentCount = 0
        }
    }

    private func reloadFromRepository() {
        guard let repository else { return }
        do {
            tasks = try repository.fetchAllTasks()
            lastErrorMessage = nil
        } catch {
            recordError(error)
        }
    }

    private func recordError(_ error: Error) {
        lastErrorMessage = error.localizedDescription
        print("TaskStore persistence error: \(error.localizedDescription)")
    }
}
