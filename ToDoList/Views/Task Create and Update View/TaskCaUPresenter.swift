//
//  TaskCaUPresenter.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import Foundation

final class TaskCaUPresenter: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var errorMessage: String? = nil
    @Published var formattedDate: String = ""
    
    private let interactor: TaskCaUInteractor
    let task: TaskEntity?
    
    init(interactor: TaskCaUInteractor, task: TaskEntity? = nil) {
        self.interactor = interactor
        self.task = task
        
        if let task = task {
            self.title = task.title ?? ""
            self.description = task.descriptionText ?? ""
        }
        
        self.formattedDate = formatDate()
    }
    
    var hasChanges: Bool {
        guard let task = task else { return false }
        return task.title != title || task.descriptionText != description
    }
    
    private var isValidInput: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty || !trimmedDescription.isEmpty
    }
    
    func saveTask(completion: @escaping () -> Void) {
        if let task = task {
            if isValidInput {
                updateTask(task: task, completion: completion)
            } else {
                deleteTask(task: task, completion: completion)
            }
        } else {
            if isValidInput {
                createTask(completion: completion)
            } else {
                completion()
            }
        }
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        if let task = task {
            return formatter.string(from: task.createdAt ?? Date())
        }
        return formatter.string(from: Date())
    }
    
    private func createTask(completion: @escaping () -> Void) {
        interactor.createTask(title: title, description: description) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                completion()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func updateTask(task: TaskEntity, completion: @escaping () -> Void) {
        interactor.updateTask(
            task: task,
            title: title,
            description: description,
            hasChanges: hasChanges,
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    completion()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        )
    }
    
    private func deleteTask(task: TaskEntity, completion: @escaping () -> Void) {
        interactor.deleteTask(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                completion()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
