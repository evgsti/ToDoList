//
//  Task.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import Foundation

struct Task: Identifiable, Decodable {
    let id: UUID
    let title: String
    let description: String
    let createdAt: Date
    let isCompleted: Bool
    
    init(description: String, isCompleted: Bool) {
        self.id = UUID()
        self.title = ""
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

struct TodosResponse: Codable {
    let todos: [TaskJSON]
}

struct TaskJSON: Codable {
    let todo: String
    let completed: Bool
}
