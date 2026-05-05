//
//  EditTaskSheet.swift
//  Counts
//

import SwiftUI

/// Native sheet for editing task fields (same structure as add flow).
struct EditTaskSheet: View {
    let taskID: UUID
    @ObservedObject var store: TaskStore

    @State private var title: String
    @State private var frequencyPerDay: Int
    @State private var description: String

    let onCancel: () -> Void
    let onSave: () -> Void

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(task: CountsTask, store: TaskStore, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) {
        taskID = task.id
        self.store = store
        _title = State(initialValue: task.title)
        _frequencyPerDay = State(initialValue: task.frequencyPerDay)
        _description = State(initialValue: task.description)
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                }

                Section("Frequency") {
                    Stepper(
                        "Times per day: \(frequencyPerDay)",
                        value: $frequencyPerDay,
                        in: 1...999
                    )
                }

                Section("Description") {
                    TextField("Notes", text: $description, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func save() {
        store.updateTask(
            id: taskID,
            title: trimmedTitle,
            frequencyPerDay: frequencyPerDay,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        onSave()
    }
}
