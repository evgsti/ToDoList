//
//  MockTaskEntity.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import Foundation
import CoreData

extension TaskEntity {
    static func previewInstance(
        title: String,
        description: String,
        createdAt: Date,
        isCompleted: Bool
    ) -> TaskEntity {
        let previewTask = TaskEntity(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        previewTask.title = title
        previewTask.descriptionText = description
        previewTask.createdAt = createdAt
        previewTask.isCompleted = isCompleted
        return previewTask
    }
}
