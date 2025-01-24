//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import Foundation
import Combine

final class TaskListInteractor {
    private let storageManager: PersistenceController
    private let networkManager: NetworkManager
    
    init(storageManager: PersistenceController, networkManager: NetworkManager) {
        self.storageManager = storageManager
        self.networkManager = networkManager
    }
    
    func fetchTasks(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            networkManager.fetchData { [weak self] fetchedTasks, error in
                guard let self = self else { return }
                
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let fetchedTasks = fetchedTasks {
                    let group = DispatchGroup()
                    
                    for task in fetchedTasks {
                        group.enter()
                        self.storageManager.addTask(
                            title: task.title,
                            descriptionText: task.description
                        ) { _ in
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.storageManager.fetchTasks { tasks in
                            completion(.success(tasks))
                        }
                    }
                }
            }
        } else {
            storageManager.fetchTasks { tasks in
                completion(.success(tasks))
            }
        }
    }
    
    func toggleTaskCompletion(task: TaskEntity, completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        storageManager.complitionToggle(task: task) { success in
            if success {
                self.storageManager.fetchTasks { tasks in
                    completion(.success(tasks))
                }
            } else {
                completion(.failure(NSError(
                    domain: "TaskError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Не удалось изменить статус задачи"]
                )))
            }
        }
    }
    
    func deleteTask(task: TaskEntity, completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        storageManager.deleteTask(task: task) { success in
            if success {
                self.storageManager.fetchTasks { tasks in
                    completion(.success(tasks))
                }
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
