//
//  TaskCaUInteractor.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import Foundation

final class TaskCaUInteractor {
    private let storageManager: PersistenceController
    
    init(storageManager: PersistenceController) {
        self.storageManager = storageManager
    }
    
    func createTask(title: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        storageManager.addTask(title: title, descriptionText: description) { success in
            if success {
                completion(.success(()))
            } else {
                completion(.failure(NSError(
                    domain: "TaskError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Не удалось создать задачу"]
                )))
            }
        }
    }
    
    func updateTask(task: TaskEntity, title: String, description: String, hasChanges: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        storageManager.updateTask(
            task: task,
            title: title,
            descriptionText: description,
            isCompleted: task.isCompleted,
            updateDate: hasChanges
        ) { success in
            if success {
                completion(.success(()))
            } else {
                completion(.failure(NSError(
                    domain: "TaskError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Не удалось обновить задачу"]
                )))
            }
        }
    }
    
    func deleteTask(task: TaskEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        storageManager.deleteTask(task: task) { success in
            if success {
                completion(.success(()))
            } else {
                completion(.failure(NSError(
                    domain: "TaskError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Не удалось удалить задачу"]
                )))
            }
        }
    }
}
