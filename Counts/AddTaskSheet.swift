//
//  AddTaskSheet.swift
//  Counts
//

import SwiftUI

/// Native sheet content for creating a task (`Form` + system toolbar).
struct AddTaskSheet: View {
    @Binding var title: String
    @Binding var frequencyPerDay: Int
    @Binding var description: String

    let onCancel: () -> Void
    let onSave: () -> Void

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
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
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: onSave)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
