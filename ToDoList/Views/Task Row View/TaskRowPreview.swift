//
//  TaskRowPreview.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

struct TaskRowPreviewView: View {
    private let viewModel: TaskRowViewModel
    
    init(viewModel: TaskRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.title)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .strikethrough(viewModel.isCompleted)
                    .frame(height: 22)
                
                if !viewModel.description.isEmpty {
                    Text(viewModel.description)
                        .font(.system(size: 12))
                        .lineLimit(10)
                        .frame(minHeight: 16)
                }
                
                Text(viewModel.createdAt())
                    .font(.system(size: 12))
                    .frame(height: 16)
                    .foregroundStyle(.gray)
            }
            .frame(width: UIScreen.main.bounds.size.width - 32, alignment: .leading)
            .foregroundStyle(viewModel.isCompleted ? .secondary : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

    }
}

#Preview {
    let task = TaskEntity.previewInstance(
        title: "Задача",
        description: "Описание задачи",
        createdAt: Date(),
        isCompleted: false
    )
    
    TaskRowPreviewView(viewModel: TaskRowViewModel(task: task))
}
