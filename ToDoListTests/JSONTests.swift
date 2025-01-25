//
//  JSONTests.swift
//  JSONTests
//
//  Created by Евгений on 24.01.2025.
//

import XCTest
@testable import ToDoList

final class JSONTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        print("NetworkManager инициализирован")
    }
    
    override func tearDown() {
        networkManager?.cancelFetch()
        networkManager = nil
        super.tearDown()
        print("NetworkManager очищен")
    }
    
    func testFetchDataAndParsing() {
        // Given
        let expectation = XCTestExpectation(description: "Загрузка и парсинг данных")
        var didReceiveCallback = false
        
        // When
        print("\nНачало загрузки данных")
        networkManager.fetchData { tasks, error in
            didReceiveCallback = true
            
            // Then
            if let error = error {
                print("\nОшибка при загрузке данных: \(error.localizedDescription)")
                expectation.fulfill()
                return
            }
            
            XCTAssertNotNil(tasks, "Массив задач не должен быть nil")
            
            if let tasks = tasks {
                print("\nЗагруженные данные")
                tasks.enumerated().forEach { index, task in
                    print("""
                        Задача #\(index + 1):
                        ID: \(task.id)
                        Заголовок: \(task.title)
                        Описание: \(task.description)
                        Создано: \(task.createdAt)
                        Выполнено: \(task.isCompleted)
                        """)
                }
                
                XCTAssertFalse(tasks.isEmpty, "Массив задач не должен быть пустым")
                
                if let firstTask = tasks.first {
                    XCTAssertFalse(firstTask.description.isEmpty, "Описание задачи не должно быть пустым")
                }
                
                print("\nВсего загружено задач: \(tasks.count)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertTrue(didReceiveCallback, "Callback должен быть вызван с ошибкой при отсутствии интернета")
    }
}

