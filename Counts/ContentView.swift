//
//  ContentView.swift
//  Counts
//
//  Created by Shubhdeep Sarkar on 5/4/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskStore = TaskStore()

    @State private var selectedDate = Date()
    @State private var calendarDraftDate = Date()
    @State private var isCalendarPresented = false
    @State private var isArchivedListPresented = false

    @State private var isAddTaskPresented = false
    @State private var draftTitle = ""
    @State private var draftFrequencyPerDay = 1
    @State private var draftDescription = ""

    private static let homeHeaderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()

    private var homeHeaderTitle: String {
        Self.homeHeaderDateFormatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    if taskStore.activeTasks.isEmpty {
                        Section {
                            ContentUnavailableView(
                                "No Tasks Yet",
                                systemImage: "checklist",
                                description: Text("Tap the add button to create a task.")
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    } else {
                        ForEach(taskStore.activeTasks) { task in
                            NavigationLink(value: task.id) {
                                taskRow(task)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .contentMargins(.top, 20, for: .scrollContent)
                .navigationTitle(homeHeaderTitle)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isArchivedListPresented = true
                        } label: {
                            Image(systemName: "archivebox")
                        }
                        .accessibilityLabel("Archived tasks")
                        .accessibilityHint("Shows tasks you have archived")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            calendarDraftDate = selectedDate
                            isCalendarPresented = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .accessibilityLabel("Choose date")
                        .accessibilityHint("Opens the calendar")
                    }
                }

                Button {
                    isAddTaskPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background {
                            Circle()
                                .fill(Color.accentColor)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add task")
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                .padding(20)
                .allowsHitTesting(!isCalendarPresented && !isAddTaskPresented && !isArchivedListPresented)
            }
            .navigationDestination(for: UUID.self) { taskID in
                TaskDetailView(taskID: taskID, store: taskStore)
            }
        }
        .sheet(isPresented: $isArchivedListPresented) {
            ArchivedTasksView(store: taskStore)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isCalendarPresented) {
            NavigationStack {
                Form {
                    DatePicker(
                        "Date",
                        selection: $calendarDraftDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                .navigationTitle("Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            isCalendarPresented = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            selectedDate = calendarDraftDate
                            isCalendarPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isAddTaskPresented, onDismiss: resetAddTaskDraft) {
            AddTaskSheet(
                title: $draftTitle,
                frequencyPerDay: $draftFrequencyPerDay,
                description: $draftDescription,
                onCancel: cancelAddTask,
                onSave: confirmAddTask
            )
        }
    }

    @ViewBuilder
    private func taskRow(_ task: CountsTask) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
            Text("\(task.currentCount) / \(task.frequencyPerDay) today")
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

    private func cancelAddTask() {
        resetAddTaskDraft()
        isAddTaskPresented = false
    }

    private func confirmAddTask() {
        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        taskStore.addTask(
            title: title,
            frequencyPerDay: draftFrequencyPerDay,
            description: draftDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        resetAddTaskDraft()
        isAddTaskPresented = false
    }

    private func resetAddTaskDraft() {
        draftTitle = ""
        draftFrequencyPerDay = 1
        draftDescription = ""
    }
}

#Preview {
    ContentView()
}
