//
//  TaskRowView.swift
//  WhatsNext
//
//  Created by Tobias Sörensson on 2026-05-07.
//
import SwiftUI

struct TaskRowView: View {
    @Bindable var task: TaskItem
    let completeTask: (TaskItem) -> Void
    let removeTask: (TaskItem) -> Void
    let currentDate: Date
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                switch task.displayState(at: currentDate) {
                case .active:
                    Button {
                        completeTask(task)
                    } label: {
                        Image(systemName: "circle")
                    }
                    .buttonStyle(.plain)

                case .completed:
                    Button {
                        task.isCompleted = false
                        task.dateCompleted = nil
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .buttonStyle(.plain)

                case .waiting:
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)

                case .deleted:
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                
                Text(task.title)
                    .foregroundStyle(task.urgencyColor(at: currentDate))
                    .strikethrough(task.displayState(at: currentDate) == .completed)
                
                Spacer()
                
                if task.displayState(at: currentDate) == .active || isExpanded {
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    
                    TextField("Title", text: $task.title)
                    
                    TextField("Notes", text: Binding(
                        get: { task.notes ?? "" },
                        set: { task.notes = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Stepper("Priority: \(task.priority)", value: $task.priority, in: 1...5)
                    
                    OptionalDatePicker(title: "Not before", date: $task.notBefore)
                    
                    OptionalDatePicker(title: "Due date", date: $task.dueDate)
                }
                .padding(.top, 8)
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                removeTask(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
