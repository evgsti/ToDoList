//
//  Persistence.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
    
    let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoList")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки Core Data: \(error), \(error.userInfo)")
            }
        }
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func fetchTasks(completion: @escaping ([TaskEntity]) -> Void) {
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let tasks = try self.backgroundContext.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Ошибка при получении задач: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func addTask(title: String, descriptionText: String, completion: @escaping (Bool) -> Void) {
        backgroundContext.perform {
            let task = TaskEntity(context: self.backgroundContext)
            task.id = UUID()
            task.title = title
            task.descriptionText = descriptionText
            task.createdAt = Date()
            task.isCompleted = false
            
            self.saveContext { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    func updateTask(task: TaskEntity, title: String, descriptionText: String, isCompleted: Bool, updateDate: Bool = false, completion: @escaping (Bool) -> Void) {
        backgroundContext.perform {
            let objectID = task.objectID
            guard let taskToUpdate = try? self.backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            taskToUpdate.title = title
            taskToUpdate.descriptionText = descriptionText
            taskToUpdate.isCompleted = isCompleted
            
            if updateDate {
                taskToUpdate.createdAt = Date()
            }
            
            self.saveContext { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    func complitionToggle(task: TaskEntity, completion: @escaping (Bool) -> Void) {
        backgroundContext.perform {
            let objectID = task.objectID
            guard let taskToUpdate = try? self.backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            taskToUpdate.isCompleted.toggle()
            
            self.saveContext { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    func deleteTask(task: TaskEntity, completion: @escaping (Bool) -> Void) {
        backgroundContext.perform {
            let objectID = task.objectID
            guard let taskToDelete = try? self.backgroundContext.existingObject(with: objectID) as? TaskEntity else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.backgroundContext.delete(taskToDelete)
            
            self.saveContext { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    private func saveContext(completion: @escaping (Bool) -> Void) {
        guard backgroundContext.hasChanges else {
            completion(true)
            return
        }
        
        do {
            try backgroundContext.save()
            completion(true)
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
            completion(false)
        }
    }
}
