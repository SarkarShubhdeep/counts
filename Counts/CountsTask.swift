//
//  CountsTask.swift
//  Counts
//

import Foundation

struct CountsTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    /// How many times this task should be done in a day.
    var frequencyPerDay: Int
    var description: String
    /// Completed count for the current period (in-app only for now).
    var currentCount: Int
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        frequencyPerDay: Int,
        description: String,
        currentCount: Int = 0,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.frequencyPerDay = max(1, frequencyPerDay)
        self.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentCount = max(0, currentCount)
        self.isArchived = isArchived
    }

    var progress: Double {
        guard frequencyPerDay > 0 else { return 0 }
        return min(Double(currentCount) / Double(frequencyPerDay), 1)
    }

    var progressPercentage: Int {
        Int((progress * 100).rounded())
    }
}
