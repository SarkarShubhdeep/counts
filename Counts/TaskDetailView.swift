//
//  TaskDetailView.swift
//  Counts
//

import SwiftUI

struct TaskDetailView: View {
    let taskID: UUID
    @ObservedObject var store: TaskStore

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var isEditing = false
    @State private var showDeleteConfirm = false

    private var task: CountsTask? {
        store.tasks.first { $0.id == taskID }
    }

    var body: some View {
        Group {
            if let task {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(task.progressSummary(mode: settings.progressDisplayMode))
                                .font(.title2.weight(.semibold))
                                .monospacedDigit()
                            Text(
                                settings.progressDisplayMode == .fraction
                                ? "\(task.progressPercentage)% complete"
                                : "\(task.currentCount) / \(task.frequencyPerDay)"
                            )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            ProgressView(value: task.progress)
                        }
                        .padding(.vertical, 4)

                        HStack(spacing: 16) {
                            Button {
                                store.adjustCount(taskID: task.id, by: -1, settings: settings)
                            } label: {
                                Image(systemName: "minus")
                                    .font(.title3.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            .disabled(task.currentCount <= 0)
                            .accessibilityLabel("Decrease count")

                            Button {
                                store.adjustCount(taskID: task.id, by: 1, settings: settings)
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel("Increase count")
                        }
                    }

                    if !task.description.isEmpty {
                        Section("Description") {
                            Text(task.description)
                        }
                    }

                    Section("Goal") {
                        LabeledContent("Times per day", value: "\(task.frequencyPerDay)")
                    }

                    if task.isArchived {
                        Section {
                            Label("Archived", systemImage: "archivebox.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section("Last 100 Days") {
                        ActivityGrid(taskID: task.id, store: store)
                    }
                }
                .navigationTitle(task.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Edit Properties…") {
                                isEditing = true
                            }

                            if task.isArchived {
                                Button("Unarchive") {
                                    store.unarchiveTask(id: task.id)
                                    dismiss()
                                }
                            } else {
                                Button("Archive") {
                                    store.archiveTask(id: task.id)
                                    dismiss()
                                }
                            }



                            Button("Delete Task", role: .destructive) {
                                showDeleteConfirm = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .accessibilityLabel("Task actions")
                    }
                }
                .sheet(isPresented: $isEditing) {
                    if let latest = store.tasks.first(where: { $0.id == taskID }) {
                        EditTaskSheet(
                            task: latest,
                            store: store,
                            onCancel: { isEditing = false },
                            onSave: { isEditing = false }
                        )
                    }
                }
                .alert("Delete Task?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        store.deleteTask(id: task.id)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("“\(task.title)” will be permanently removed.")
                }
            } else {
                ContentUnavailableView(
                    "Task not found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This task may have been removed.")
                )
            }
        }
    }
}

#Preview {
    let previewStore = TaskStore(
        tasks: [
            CountsTask(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: "Push-ups",
                frequencyPerDay: 50,
                description: "Spread sets across the day.",
                currentCount: 12
            )
        ]
    )

    return NavigationStack {
        TaskDetailView(
            taskID: previewStore.tasks[0].id,
            store: previewStore
        )
    }
    .environmentObject(AppSettings())
}


