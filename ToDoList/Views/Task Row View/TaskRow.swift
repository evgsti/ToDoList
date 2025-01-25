//
//  TaskRow.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

struct TaskRow: View {
    let viewModel: TaskRowViewModel
    let checkAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        let tint = Color("tint")
        let check = Image(.check).foregroundStyle(tint)
        
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    checkAction()
                } label: {
                    Circle()
                        .stroke(viewModel.isCompleted ? tint : .secondary, lineWidth: 1)
                        .frame(width: 24, height: 24)
                        .overlay(viewModel.isCompleted ? check : nil)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .strikethrough(viewModel.isCompleted)
                        .frame(height: 24)
                    
                    if !viewModel.description.isEmpty {
                        Text(viewModel.description)
                            .font(.system(size: 12))
                            .lineLimit(2)
                            .frame(minHeight: 16, maxHeight: 32)
                    }
                    
                    Text(viewModel.createdAt())
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(height: 16)
                }
                .foregroundStyle(viewModel.isCompleted ? .secondary : .primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundStyle(Color("stroke"))
        }
        .contentShape(Rectangle()) 
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

#Preview {
    let task1 = TaskEntity.previewInstance(
        title: "Задача 1",
        description: "Описание первой задачи",
        createdAt: Date(),
        isCompleted: false
    )
    
    let task2 = TaskEntity.previewInstance(
        title: "Задача 2",
        description: "Описание второй задачи",
        createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        isCompleted: true
    )
    
    let tasks = [task1, task2].map { TaskRowViewModel(task: $0) }
    
    VStack(spacing: 0) {
        ForEach(tasks, id: \.task.objectID) { viewModel in
            TaskRow(
                viewModel: viewModel,
                checkAction: {
                    print("Нажал выполнено")
                },
                deleteAction: {
                    print("Нажал удалить")
                }
            )
        }
        .padding(.horizontal)
    }
}
