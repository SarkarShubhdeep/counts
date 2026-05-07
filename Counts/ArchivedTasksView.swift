//
//  ArchivedTasksView.swift
//  Counts
//

import SwiftUI

/// Archived task list; supports open detail, unarchive, delete.
struct ArchivedTasksView: View {
    @ObservedObject var store: TaskStore
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Group {
            if store.archivedTasks.isEmpty {
                ContentUnavailableView(
                    "No Archived Tasks",
                    systemImage: "archivebox",
                    description: Text("Tasks you archive will appear here.")
                )
            } else {
                List {
                    ForEach(store.archivedTasks) { task in
                        NavigationLink(value: task.id) {
                            archivedRow(task)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                store.deleteTask(id: task.id)
                            }

                            Button("Unarchive") {
                                store.unarchiveTask(id: task.id)
                            }
                            .tint(.indigo)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Archived")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: UUID.self) { taskID in
            TaskDetailView(taskID: taskID, store: store)
        }
    }
    
    private func archivedRow(_ task: CountsTask) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
            Text(task.progressSummary(mode: settings.progressDisplayMode))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let previewStore = TaskStore(
        tasks: [
            CountsTask(
                title: "Read pages",
                frequencyPerDay: 20,
                description: "Any book or article.",
                currentCount: 7,
                isArchived: true
            ),
            CountsTask(
                title: "Water glasses",
                frequencyPerDay: 8,
                description: "8 oz each.",
                currentCount: 5,
                isArchived: true
            ),
            CountsTask(
                title: "Push-ups",
                frequencyPerDay: 50,
                description: "Spread sets across the day.",
                currentCount: 12,
                isArchived: false
            )
        ]
    )

    return NavigationStack {
        ArchivedTasksView(store: previewStore)
    }
    .environmentObject(AppSettings())
}
