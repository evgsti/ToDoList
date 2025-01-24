//
//  TaskContextMenuView.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

struct TaskRowContextMenuView: View {
    let edit: () -> Void
    let share: () -> Void
    let delete: () -> Void
    
    var body: some View {
        createButton(label: "Редактировать", image: "edit", action: edit)
        createButton(label: "Поделиться", image: "export", action: share)
        createButton(label: "Удалить", image: "trash", action: delete, role: .destructive)
    }
    
    private func createButton(
        label: String,
        image: String,
        action: @escaping () -> Void,
        role: ButtonRole? = nil
    ) -> some View {
        Button(role: role) {
            action()
        } label: {
            Label(label, image: image)
                .frame(width: 16, height: 16)
                .foregroundStyle(.buttonTint)
        }
    }
}

#Preview {
    TaskRowContextMenuView(
            edit: {
                print("Нажал редактировать")
            },
            share: {
                print("Нажал поделиться")
            },
            delete: {
                print("Нажал удалить")
            }
    )
}
