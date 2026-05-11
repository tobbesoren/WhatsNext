//
//  TaskItem.swift
//  WhatsNext
//
//  Created by Tobias Sörensson on 2026-05-07.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class TaskItem {
    
    enum TaskDisplayState {
            case active
            case waiting
            case completed
            case archived
        }
    
    var title: String
    var notes: String?
    var priority: Int
    var createdAt: Date
    var notBefore: Date?
    var dueDate: Date?
    var isCompleted: Bool
    var isArchived: Bool
    var dateCompleted: Date?
    
    func displayState(at date: Date) -> TaskDisplayState {
        if isArchived { return .archived }
        if isCompleted { return .completed }

        if let notBefore, notBefore > date {
            return .waiting
        }

        return .active
    }
    
    func sortScore(at date: Date) -> Int {
        var score = priority * 100

        if let dueDate {
            let daysLeft = Calendar.current.dateComponents([.day], from: date, to: dueDate).day ?? 0

            if daysLeft <= 0 {
                score += 1000
            } else if daysLeft == 1 {
                score += 500
            } else if daysLeft <= 3 {
                score += 250
            } else if daysLeft <= 7 {
                score += 100
            }
        }

        return score
    }
    
    func urgencyColor(at date: Date) -> Color {
        guard displayState(at: date) == .active else {
            return .secondary
        }

        guard let dueDate else {
            return .blue
        }

        let hoursLeft = Calendar.current.dateComponents([.hour], from: date, to: dueDate).hour ?? 0

        if hoursLeft < 0 {
            return .red
        }

        let priorityBoost = Double(priority - 1) / 4.0

        if hoursLeft <= 24 {
            return priorityBoost > 0.5 ? .red : .orange
        } else if hoursLeft <= 72 {
            return priorityBoost > 0.5 ? .orange : .yellow
        } else if hoursLeft <= 168 {
            return priorityBoost > 0.5 ? .yellow : .green
        } else {
            return priorityBoost > 0.5 ? .green : .blue
        }
    }
    
    init(
        title: String,
         notes: String? = nil,
         priority: Int = 1,
        createdAt: Date = .now,
         notBefore: Date? = nil,
         dueDate: Date? = nil,
         isCompleted: Bool = false,
         isArchived: Bool = false,
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
        self.isArchived = isArchived
        self.dateCompleted = dateCompleted
    }
}
