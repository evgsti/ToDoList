//
//  TaskToolbarView.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import SwiftUI

struct ListToolbarView: View {
    
    @ObservedObject var viewModel: ListToolbarViewModel
    
    var body: some View {
        ZStack {
            Text("\(viewModel.tasksCount) \(viewModel.getTaskCountText())")
                .font(.subheadline)
            HStack {
                Spacer()
                
                NavigationLink {
                    TaskListRouter.shared.makeTaskCreateAndUpdate(task: nil)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .foregroundStyle(viewModel.disableStatus ? .primary : Color("tint"))
                .disabled(viewModel.disableStatus)
            }
        }
    }
}

#Preview {
    ListToolbarView(
        viewModel: ListToolbarViewModel(
            tasks: [
                TaskEntity.previewInstance(
                    title: "",
                    description: "",
                    createdAt: Date(),
                    isCompleted: false
                )
            ],
            disableStatus: false
        )
    )
}
