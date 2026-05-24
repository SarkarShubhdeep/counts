//
//  TaskRepository.swift
//  Counts
//

import Foundation

protocol TaskRepository {
    func fetchAllTasks() throws -> [CountsTask]
    func addTask(title: String, frequencyPerDay: Int, description: String) throws
    func adjustCount(taskID: UUID, by delta: Int) throws
    func updateTask(id: UUID, title: String, frequencyPerDay: Int, description: String) throws
    func setArchived(taskID: UUID, isArchived: Bool) throws
    func deleteTask(taskID: UUID) throws
    func resetCountsForActiveTasks() throws
    
    func recordDailyProgress(taskID: UUID, count: Int, goal: Int, date: Date) throws
    func fetchDailyRecords(taskID: UUID, lastDays: Int) throws -> [Date: (count: Int, goal: Int)]
}
