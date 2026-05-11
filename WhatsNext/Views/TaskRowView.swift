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
    let archiveTask: (TaskItem) -> Void
    let restoreTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let currentDate: Date
    
    @State private var isExpanded = false
    @State private var originalTitle: String = ""
    @State private var draftTitle = ""
    @State private var draftNotes = ""
    @State private var draftPriority = 1
    @State private var draftNotBefore: Date?
    @State private var draftDueDate: Date?
    
    private func loadDraft() {
        originalTitle = task.title
        draftTitle = task.title
        draftNotes = task.notes ?? ""
        draftPriority = task.priority
        draftNotBefore = task.notBefore
        draftDueDate = task.dueDate
    }
    
    private func saveDraft() {
        task.title = draftTitle.isEmpty ? originalTitle : draftTitle
        task.notes = draftNotes.isEmpty ? nil : draftNotes
        task.priority = draftPriority
        task.notBefore = draftNotBefore
        task.dueDate = draftDueDate
    }
    
    private func toggleExpanded() {
        if isExpanded {
            saveDraft()
        } else {
            loadDraft()
        }
            isExpanded.toggle()
    }
    
    private var canArchive: Bool {
        !isExpanded
    }
    
    private var canEdit: Bool {
        let state = task.displayState(at: currentDate)
        return state == .active || state == .waiting
    }
    
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

                case .archived:
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                
                Text(task.title)
                    .foregroundStyle(task.urgencyColor(at: currentDate))
                    .strikethrough(task.displayState(at: currentDate) == .completed)
               
                Spacer()
                
                if canEdit || isExpanded {
                    Button {
                        toggleExpanded()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    
                    TextField("Title", text: $draftTitle)
                    
                    TextField("Notes", text: $draftNotes)
                    
                    Stepper("Priority: \(draftPriority)", value: $draftPriority, in: 1...5)
                    
                    OptionalDatePicker(title: "Not before", date: $draftNotBefore)
                    
                    OptionalDatePicker(title: "Due date", date: $draftDueDate)
                }
                .padding(.top, 8)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            if !isExpanded {
                if task.displayState(at: currentDate) == .archived {
                    Button(role: .destructive) {
                        restoreTask(task)
                    } label: {
                        Label("Restore", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.blue)

                    Button(role: .destructive) {
                        deleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                    
                } else {
                    Button(role: .destructive) {
                        archiveTask(task)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.orange)
                }
            }
        }
    }
}
