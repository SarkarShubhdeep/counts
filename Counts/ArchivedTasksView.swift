//
//  ArchivedTasksView.swift
//  Counts
//

import SwiftUI

/// Sheet listing archived tasks; supports open detail, unarchive, delete.
struct ArchivedTasksView: View {
    @ObservedObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: UUID.self) { taskID in
                TaskDetailView(taskID: taskID, store: store)
            }
        }
    }

    private func archivedRow(_ task: CountsTask) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
            Text("\(task.currentCount) / \(task.frequencyPerDay)")
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
