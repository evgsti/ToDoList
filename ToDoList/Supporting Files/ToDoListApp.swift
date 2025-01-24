//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TaskListRouter.shared.makeTaskList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
