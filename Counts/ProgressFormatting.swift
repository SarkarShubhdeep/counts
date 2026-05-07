//
//  ProgressFormatting.swift
//  Counts
//

import Foundation

extension CountsTask {
    func progressSummary(mode: AppSettings.ProgressDisplayMode, includeTodaySuffix: Bool = false) -> String {
        switch mode {
        case .fraction:
            let suffix = includeTodaySuffix ? " today" : ""
            return "\(currentCount) / \(frequencyPerDay)\(suffix)"
        case .percent:
            return "\(progressPercentage)% complete"
        }
    }
}
