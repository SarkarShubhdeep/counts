//
//  TaskEntity.swift
//  Counts
//

import Foundation
import SwiftData

@Model
final class TaskEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var frequencyPerDay: Int
    var taskDescription: String
    var currentCount: Int
    var isArchived: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        frequencyPerDay: Int,
        taskDescription: String,
        currentCount: Int = 0,
        isArchived: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.frequencyPerDay = max(1, frequencyPerDay)
        self.taskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentCount = max(0, currentCount)
        self.isArchived = isArchived
        self.createdAt = createdAt
    }
}

extension TaskEntity {
    var asCountsTask: CountsTask {
        CountsTask(
            id: id,
            title: title,
            frequencyPerDay: frequencyPerDay,
            description: taskDescription,
            currentCount: currentCount,
            isArchived: isArchived
        )
    }
}
