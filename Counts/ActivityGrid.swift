//
//  ActivityGrid.swift
//  Counts
//

import SwiftUI

struct ActivityGrid: View {
    let taskID: UUID
    @ObservedObject var store: TaskStore
    
    private let columns = 10
    private let totalDays = 100
    
    @EnvironmentObject private var settings: AppSettings
    
    private var progressData: [(progress: Double, goalMet: Bool)] {
        let records = store.fetchDailyRecords(taskID: taskID, lastDays: totalDays)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<totalDays).map { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return (progress: 0, goalMet: false)
            }
            if let record = records[date] {
                let progress = record.goal > 0 ? min(Double(record.count) / Double(record.goal), 1.0) : 0
                let goalMet = record.count >= record.goal
                return (progress: progress, goalMet: goalMet)
            }
            return (progress: 0, goalMet: false)
        }
    }
    
    private var rows: Int {
        (totalDays + columns - 1) / columns
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                let spacing: CGFloat = 6
                let totalSpacing = spacing * CGFloat(columns - 1)
                let dotSize = (geometry.size.width - totalSpacing) / CGFloat(columns)
                
                Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        GridRow {
                            ForEach(0..<columns, id: \.self) { col in
                                let dayIndex = row * columns + col
                                if dayIndex < totalDays {
                                    let data = progressData[dayIndex]
                                    ActivityDot(
                                        progress: data.progress,
                                        goalMet: data.goalMet,
                                        accentColor: settings.accentColorName.color,
                                        size: dotSize
                                    )
                                } else {
                                    Color.clear
                                        .frame(width: dotSize, height: dotSize)
                                }
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(settings.accentColorName.color)
                        .frame(width: 8, height: 8)
                    Text("Goal met")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Circle()
                        .stroke(settings.accentColorName.color, lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                    Text("In progress")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 8, height: 8)
                    Text("No activity")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ActivityDot: View {
    let progress: Double
    let goalMet: Bool
    let accentColor: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if goalMet {
                Circle()
                    .fill(accentColor)
            } else if progress > 0 {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: size * 0.15)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: size * 0.15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            } else {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    Form {
        Section("Last 100 Days") {
            ActivityGrid(taskID: UUID(), store: TaskStore())
        }
    }
    .environmentObject(AppSettings())
}
