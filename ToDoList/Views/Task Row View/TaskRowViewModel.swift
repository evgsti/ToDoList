//
//  TaskRowViewModel.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import Foundation

final class TaskRowViewModel {
    let task: TaskEntity
        
    init(task: TaskEntity) {
        self.task = task
    }
    
    var title: String {
        if let title = task.title, !title.isEmpty {
            return title
        }
        return task.descriptionText ?? "No Title"
    }
    
    var description: String {
        if let title = task.title, !title.isEmpty {
            return task.descriptionText ?? "No description"
        }
        return ""
    }
    
    var createdAtDate: Date {
        task.createdAt ?? Date()
    }
    
    var isCompleted: Bool {
        task.isCompleted
    }
        
    func createdAt() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: createdAtDate)
    }
    
    func shareText() -> String {
        var text = title
        
        if !description.isEmpty {
            text += "\n\n\(description)"
        }
        
        text += "\n\nСоздано: \(createdAt())"
        text += "\nСтатус: \(isCompleted ? "Выполнено" : "Не выполнено")"
        
        return text
    }
}
