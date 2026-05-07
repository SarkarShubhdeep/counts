//
//  ContentView.swift
//  Counts
//
//  Created by Shubhdeep Sarkar on 5/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    @StateObject private var taskStore = TaskStore()

    @State private var selectedDate = Date()
    @State private var calendarDraftDate = Date()
    @State private var isCalendarPresented = false
    @State private var isSettingsPresented = false

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
                                "No Counts Yet",
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
                .contentMargins(.bottom, 96, for: .scrollContent)
                .navigationTitle(homeHeaderTitle)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            ArchivedTasksView(store: taskStore)
                        } label: {
                            Image(systemName: "archivebox")
                        }
                        .accessibilityLabel("Archived tasks")
                        .accessibilityHint("Shows tasks you have archived")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 14) {
                            Button {
                                isSettingsPresented = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityHint("Opens app settings")

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
                }

                Button {
                    taskStore.applyAutomaticResetIfNeeded(settings: settings)
                    draftFrequencyPerDay = settings.defaultFrequencyPerDay
                    isAddTaskPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background {
                            Circle()
                                .fill(settings.accentColorName.color)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add task")
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                .padding(20)
                .allowsHitTesting(!isCalendarPresented && !isAddTaskPresented)
            }
            .navigationDestination(for: UUID.self) { taskID in
                TaskDetailView(taskID: taskID, store: taskStore)
            }
        }
        .onAppear {
            taskStore.configurePersistence(modelContext: modelContext)
            taskStore.applyAutomaticResetIfNeeded(settings: settings)
            if draftTitle.isEmpty {
                draftFrequencyPerDay = settings.defaultFrequencyPerDay
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                taskStore.applyAutomaticResetIfNeeded(settings: settings)
            }
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
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(settings: settings) {
                isSettingsPresented = false
            }
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
            Text(task.progressSummary(mode: settings.progressDisplayMode, includeTodaySuffix: true))
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
            description: draftDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            settings: settings
        )
        resetAddTaskDraft()
        isAddTaskPresented = false
    }

    private func resetAddTaskDraft() {
        draftTitle = ""
        draftFrequencyPerDay = settings.defaultFrequencyPerDay
        draftDescription = ""
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
