//
//  ListToolbarViewModel.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import Combine

final class ListToolbarViewModel: ObservableObject {
    
    @Published var tasks: [TaskEntity] = [] {
        didSet {
            tasksCount = tasks.count
        }
    }
    
    @Published var disableStatus: Bool
    @Published private(set) var tasksCount = 0
    
    init(tasks: [TaskEntity], disableStatus: Bool) {
        self.tasks = tasks
        self.disableStatus = disableStatus
        self.tasksCount = tasks.count
    }
    
    func getTaskCountText() -> String {
        let lastDigit = tasksCount % 10
        let lastTwoDigits = tasksCount % 100
        
        if (lastTwoDigits >= 11 && lastTwoDigits <= 14) || lastDigit == 0 || lastDigit >= 5 {
            return "Задач"
        }
        return lastDigit == 1 ? "Задача" : "Задачи"
    }
}
