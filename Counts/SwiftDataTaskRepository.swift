//
//  SwiftDataTaskRepository.swift
//  Counts
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataTaskRepository: TaskRepository {
    private let context: ModelContext

    init(modelContext: ModelContext) {
        context = modelContext
    }

    func fetchAllTasks() throws -> [CountsTask] {
        var descriptor = FetchDescriptor<TaskEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.includePendingChanges = true
        let entities = try context.fetch(descriptor)
        return entities.map(\.asCountsTask)
    }

    func addTask(title: String, frequencyPerDay: Int, description: String) throws {
        let entity = TaskEntity(
            title: title,
            frequencyPerDay: frequencyPerDay,
            taskDescription: description
        )
        context.insert(entity)
        try context.save()
    }

    func adjustCount(taskID: UUID, by delta: Int) throws {
        guard let entity = try fetchEntity(taskID: taskID) else { return }
        entity.currentCount = max(0, entity.currentCount + delta)
        try context.save()
    }

    func updateTask(id: UUID, title: String, frequencyPerDay: Int, description: String) throws {
        guard let entity = try fetchEntity(taskID: id) else { return }
        entity.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        entity.frequencyPerDay = max(1, frequencyPerDay)
        entity.taskDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        try context.save()
    }

    func setArchived(taskID: UUID, isArchived: Bool) throws {
        guard let entity = try fetchEntity(taskID: taskID) else { return }
        entity.isArchived = isArchived
        try context.save()
    }

    func deleteTask(taskID: UUID) throws {
        guard let entity = try fetchEntity(taskID: taskID) else { return }
        context.delete(entity)
        try context.save()
    }

    func resetCountsForActiveTasks() throws {
        var descriptor = FetchDescriptor<TaskEntity>(
            predicate: #Predicate { !$0.isArchived }
        )
        descriptor.includePendingChanges = true
        let entities = try context.fetch(descriptor)
        for entity in entities {
            entity.currentCount = 0
        }
        try context.save()
    }

    private func fetchEntity(taskID: UUID) throws -> TaskEntity? {
        let descriptor = FetchDescriptor<TaskEntity>(
            predicate: #Predicate { $0.id == taskID }
        )
        return try context.fetch(descriptor).first
    }
    
    func recordDailyProgress(taskID: UUID, count: Int, goal: Int, date: Date) throws {
        let normalizedDate = DailyRecordEntity.normalizeDate(date)
        
        let descriptor = FetchDescriptor<DailyRecordEntity>(
            predicate: #Predicate { $0.taskID == taskID && $0.date == normalizedDate }
        )
        
        if let existing = try context.fetch(descriptor).first {
            existing.count = max(0, count)
            existing.goal = max(1, goal)
        } else {
            let record = DailyRecordEntity(taskID: taskID, date: date, count: count, goal: goal)
            context.insert(record)
        }
        try context.save()
    }
    
    func fetchDailyRecords(taskID: UUID, lastDays: Int) throws -> [Date: (count: Int, goal: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(lastDays - 1), to: today) else {
            return [:]
        }
        
        let descriptor = FetchDescriptor<DailyRecordEntity>(
            predicate: #Predicate { $0.taskID == taskID && $0.date >= startDate }
        )
        
        let records = try context.fetch(descriptor)
        var result: [Date: (count: Int, goal: Int)] = [:]
        for record in records {
            result[record.date] = (count: record.count, goal: record.goal)
        }
        return result
    }
}
