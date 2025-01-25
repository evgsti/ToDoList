//
//  CoreDataTests.swift
//  ToDoList
//
//  Created by Евгений on 24.01.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class CoreDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    static var modelName = "ToDoList"
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        print("База данных инициализирована")
    }
    
    override func tearDown() {
        persistenceController = nil
        super.tearDown()
        print("База данных очищена")
    }
    
    func testAddTaskSucceedsWithValidInput() {
        // Given
        let title = "Тестовая задача"
        let description = "Описание тестовой задачи"
        let expectation = XCTestExpectation(description: "Добавление задачи")
        
        // When
        print("Добавление новой задачи")
        self.persistenceController.addTask(title: title, descriptionText: description) { success in
            
            // Then
            XCTAssertTrue(success, "Задача должна быть успешно создана")
            
            self.persistenceController.fetchTasks { tasks in
                XCTAssertEqual(tasks.count, 1, "Должна быть одна задача")
                XCTAssertEqual(tasks.first?.title, title, "Название задачи должно совпадать")
                XCTAssertEqual(tasks.first?.descriptionText, description, "Описание задачи должно совпадать")
                print("Задача успешно добавлена")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateTaskSucceedsWithNewTitleAndDescription() {
        // Given
        let initialTitle = "Тестовая задача"
        let initialDescription = "Описание тестовой задачи"
        let updatedTitle = "Обновленная задача"
        let updatedDescription = "Обновленное описание задачи"
        let expectation = XCTestExpectation(description: "Обновление задачи")
        
        // When
        self.persistenceController.addTask(title: initialTitle, descriptionText: initialDescription) { _ in
            self.persistenceController.fetchTasks { tasks in
                guard let task = tasks.first else {
                    XCTFail("Задача для обновления не найдена")
                    return
                }
                
                print("Обновление задачи")
                self.persistenceController.updateTask(
                    task: task,
                    title: updatedTitle,
                    descriptionText: updatedDescription,
                    isCompleted: false
                ) { success in
                    
                    // Then
                    XCTAssertTrue(success, "Задача должна быть успешно обновлена")
                    
                    self.persistenceController.fetchTasks { tasks in
                        XCTAssertEqual(tasks.count, 1, "Должна остаться одна задача")
                        XCTAssertEqual(tasks.first?.title, updatedTitle, "Название задачи должно быть обновлено")
                        XCTAssertEqual(tasks.first?.descriptionText, updatedDescription, "Описание задачи должно быть обновлено")
                        print("Задача успешно обновлена")
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTaskSucceedsWhenTaskExists() {
        // Given
        let title = "Тестовая задача"
        let description = "Описание тестовой задачи"
        let expectation = XCTestExpectation(description: "Удаление задачи")
        
        // When
        self.persistenceController.addTask(title: title, descriptionText: description) { _ in
            self.persistenceController.fetchTasks { tasks in
                guard let taskToDelete = tasks.first else {
                    XCTFail("Задача для удаления не найдена")
                    return
                }
                
                print("Удаление задачи")
                self.persistenceController.deleteTask(task: taskToDelete) { success in
                    
                    // Then
                    XCTAssertTrue(success, "Задача должна быть успешно удалена")
                    
                    self.persistenceController.fetchTasks { tasks in
                        XCTAssertEqual(tasks.count, 0, "База данных должна быть пуста")
                        
                        print("Задача успешно удалена")
                        
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
