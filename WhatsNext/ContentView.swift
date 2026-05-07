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
    @Query private var tasks: [TaskItem]
    
    var activeTasks: [TaskItem] {
        tasks
            .filter { $0.displayState == .active }
            .sorted {
                if $0.sortScore != $1.sortScore {
                    return $0.sortScore > $1.sortScore
                }
                
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt < $1.createdAt
                }
                
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
    }

    var waitingTasks: [TaskItem] {
        tasks
            .filter { $0.displayState == .waiting }
            .sorted {
                ($0.notBefore ?? .distantFuture) < ($1.notBefore ?? .distantFuture)
            }
    }

    var completedTasks: [TaskItem] {
        tasks
            .filter { $0.displayState == .completed }
            .sorted {
                ($0.dateCompleted ?? .distantPast) > ($1.dateCompleted ?? .distantPast)
            }
    }

    var deletedTasks: [TaskItem] {
        tasks.filter { $0.displayState == .deleted }
    }

    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("New task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addTask()
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
                                removeTask: removeTask
                            )
                        }
                    }
                    
                    Section("Later") {
                        ForEach(waitingTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                removeTask: removeTask
                            )
                        }
                    }
                    
                    Section("Done") {
                        ForEach(completedTasks) { task in
                            TaskRowView(
                                task: task,
                                completeTask: completeTask,
                                removeTask: removeTask
                            )
                        }
                    }
                }
            }
            .navigationTitle("WhatsNext")
        }
    }
    
    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else { return }
        
        let task = TaskItem(title: trimmedTitle)
        modelContext.insert(task)
        
        newTaskTitle = ""
    }
    
    private func completeTask(_ task: TaskItem) {
        task.isCompleted = true
        task.dateCompleted = .now
    }
    
    private func removeTask(_ task: TaskItem) {
        task.isDeleted = true
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
