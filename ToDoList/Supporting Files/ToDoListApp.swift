//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

@main
struct ToDoListApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TaskListRouter.shared.makeTaskList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                    UserDefaults.standard.set(true, forKey: "hasFetchedADataBefore")
                }
            }
        }
    }
}
