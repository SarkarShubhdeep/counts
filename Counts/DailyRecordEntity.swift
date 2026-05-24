//
//  DailyRecordEntity.swift
//  Counts
//

import Foundation
import SwiftData

@Model
final class DailyRecordEntity {
    var taskID: UUID
    var date: Date
    var count: Int
    var goal: Int
    
    init(taskID: UUID, date: Date, count: Int, goal: Int) {
        self.taskID = taskID
        self.date = DailyRecordEntity.normalizeDate(date)
        self.count = max(0, count)
        self.goal = max(1, goal)
    }
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(count) / Double(goal), 1.0)
    }
    
    var goalMet: Bool {
        count >= goal
    }
    
    static func normalizeDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
