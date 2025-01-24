//
//  TaskListPresenter.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import Foundation
import Combine

final class TaskListPresenter: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var disableStatus = false
    @Published var errorMessage: String? = nil
    
    private let interactor: TaskListInteractor
    private let networkManager: NetworkManager
    
    var filteredTasks: [TaskEntity] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { task in
            let searchQuery = searchText.lowercased()
            let titleMatch = task.title?.lowercased().contains(searchQuery) ?? false
            let descriptionMatch = task.descriptionText?.lowercased().contains(searchQuery) ?? false
            return titleMatch || descriptionMatch
        }
    }
    
    init(interactor: TaskListInteractor) {
        self.interactor = interactor
        self.networkManager = NetworkManager.shared
    }
    
    func loadTasks() {
        isLoading = true
        disableStatus = true
                
        interactor.fetchTasks { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.disableStatus = false

            switch result {
            case .success(let fetchedTasks):
                self.tasks = fetchedTasks
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleTaskCompletion(task: TaskEntity) {
        interactor.toggleTaskCompletion(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTasks):
                self.tasks = updatedTasks
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func cancelLoading() {
        networkManager.cancelFetch()
        isLoading = false
        disableStatus = false
    }
    
    func deleteTask(task: TaskEntity) {
        interactor.deleteTask(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTasks):
                self.tasks = updatedTasks
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
