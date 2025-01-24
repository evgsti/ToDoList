//
//  TaskListRouter.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import SwiftUI

protocol TaskRouterProtocol {
    func makeTaskList() -> TaskList
    func makeTaskCreateAndUpdate(task: TaskEntity?) -> TaskCreateAndUpdateView
}

final class TaskListRouter: TaskRouterProtocol {
    
    static let shared = TaskListRouter()
    
    private init() {}
    
    func makeTaskList() -> TaskList {
        let interactor = TaskListInteractor(
            storageManager: PersistenceController.shared,
            networkManager: NetworkManager.shared
        )
        let presenter = TaskListPresenter(interactor: interactor)
        return TaskList(presenter: presenter)
    }
    
    func makeTaskCreateAndUpdate(task: TaskEntity?) -> TaskCreateAndUpdateView {
        let interactor = TaskCaUInteractor(storageManager: PersistenceController.shared)
        let presenter = TaskCaUPresenter(interactor: interactor, task: task)
        return TaskCreateAndUpdateView(presenter: presenter)
    }
}
