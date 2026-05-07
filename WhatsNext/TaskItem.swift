//
//  TaskItem.swift
//  WhatsNext
//
//  Created by Tobias Sörensson on 2026-05-07.
//

import Foundation
import SwiftData

@Model
class TaskItem {
    var title: String
    var notes: String?
    var priority: Int
    var createdAt: Date
    var notBefore: Date?
    var dueDate: Date?
    var isCompleted: Bool
    var isDeleted: Bool
    var dateCompleted: Date?
    // var subTasks: SubTasks?
    
    init(
        title: String,
         notes: String? = nil,
         priority: Int = 1,
        createdAt: Date = .now,
         notBefore: Date? = nil,
         dueDate: Date? = nil,
         isCompleted: Bool = false,
         isDeleted: Bool = false,
         dateCompleted: Date? = nil
    )
    {
        self.title = title
        self.notes = notes
        self.priority = priority
        self.createdAt = createdAt
        self.notBefore = notBefore
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.isDeleted = isDeleted
        self.dateCompleted = dateCompleted
    }
}
