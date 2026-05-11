//
//  ContentView.swift
//  WhatsNext
//
//  Created by Tobias Sörensson on 2026-05-07.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var tasks: [TaskItem]
    @State private var refreshDate = Date()
    @FocusState private var isAddingTaskFocused: Bool
    
    var activeTasks: [TaskItem] {
        let now = refreshDate
        
        return tasks
            .filter { $0.displayState(at: now) == .active }
            .sorted {
                if $0.sortScore(at: now) != $1.sortScore(at: now) {
                    return $0.sortScore(at: now) > $1.sortScore(at: now)
                }

                if $0.createdAt != $1.createdAt {
                    return $0.createdAt < $1.createdAt
                }

                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
    }

    var waitingTasks: [TaskItem] {
        let now = refreshDate
        return tasks
            .filter { $0.displayState(at: now) == .waiting }
            .sorted {
                ($0.notBefore ?? .distantFuture) < ($1.notBefore ?? .distantFuture)
            }
    }

    var completedTasks: [TaskItem] {
        let now = refreshDate
        return tasks
            .filter { $0.displayState(at: now) == .completed }
            .sorted {
                ($0.dateCompleted ?? .distantPast) > ($1.dateCompleted ?? .distantPast)
            }
    }

    var archivedTasks: [TaskItem] {
        let now = refreshDate
        
        return tasks.filter { $0.displayState(at: now) == .archived }
    }

    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("New task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .focused($isAddingTaskFocused)
                        .onSubmit {
                            addTask()
                        }
                        .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()

                                    Button {
                                        isAddingTaskFocused = false
                                    } label: {
                                        Image(systemName: "keyboard.chevron.compact.down")
                                    }
                                }
                            }
                    
                    Button("Add") {
                        addTask()
                    }
                }
                .padding()
                
                List {
                    
                    Section("Now") {
                        ForEach(activeTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                archiveTask: archiveTask,
                                restoreTask: restoreTask,
                                deleteTask: deleteTask,
                                currentDate: refreshDate
                            )
                        }
                    }
                    
                    Section("Later") {
                        ForEach(waitingTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                archiveTask: archiveTask,
                                restoreTask: restoreTask,
                                deleteTask: deleteTask,
                                currentDate: refreshDate
                            )
                        }
                    }
                    
                    Section("Done") {
                        ForEach(completedTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                archiveTask: archiveTask,
                                restoreTask: restoreTask,
                                deleteTask: deleteTask,
                                currentDate: refreshDate
                            )
                        }
                    }
                    
                    Section("Archived") {
                        ForEach(archivedTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                archiveTask: archiveTask,
                                restoreTask: restoreTask,
                                deleteTask: deleteTask,
                                currentDate: refreshDate
                            )
                        }
                    }
                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    isAddingTaskFocused = false
//                }
            }
            .navigationTitle("WhatsNext")
        }.onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshDate = .now
            }
        }
    }
    
    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            isAddingTaskFocused = true
            return
        }
        
        let task = TaskItem(title: trimmedTitle)
        modelContext.insert(task)
        
        newTaskTitle = ""
        isAddingTaskFocused = true // probably unnecessary?
    }
    
    private func completeTask(_ task: TaskItem) {
        task.isCompleted = true
        task.dateCompleted = .now
    }
    
    private func archiveTask(_ task: TaskItem) {
            withAnimation {
                task.isArchived = true
            }
    }
    
    private func restoreTask(_ task: TaskItem) {
            withAnimation {
                task.isArchived = false
            }
    }
    
    private func deleteTask(_ task: TaskItem) {
            modelContext.delete(task)
    }
}

#Preview {
    
    let container = try! ModelContainer(
        for: TaskItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    context.insert(TaskItem(title: "Buy milk"))
    context.insert(TaskItem(title: "Call dentist", priority: 3))
    context.insert(TaskItem(title: "Finish iOS app"))
    
    return ContentView()
        .modelContainer(container)
}
