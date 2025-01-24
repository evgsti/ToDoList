//
//  ContentView.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

struct TaskList: View {
    @StateObject private var presenter: TaskListPresenter
    
    init(presenter: TaskListPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(presenter.filteredTasks) { task in
                    TaskRow(
                        viewModel: TaskRowViewModel(task: task),
                        checkAction: {
                            presenter.toggleTaskCompletion(task: task)
                        },
                        deleteAction: {
                            withAnimation {
                                presenter.deleteTask(task: task)
                            }
                        }
                    )
                }
                .searchable(
                    text: $presenter.searchText,
                    prompt: "Search"
                )
                .disabled(presenter.disableStatus)
                
                if presenter.isLoading {
                    VStack(spacing: 10) {
                        ProgressView("Загрузка...")
                            .progressViewStyle(CircularProgressViewStyle())
                        
                        Button("Отменить") {
                            presenter.cancelLoading()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationBarTitle("Задачи")
            .listStyle(PlainListStyle())
            .onAppear {
                presenter.loadTasks()
            }
            .alert("Ошибка", isPresented: Binding(
                get: { presenter.errorMessage != nil },
                set: { if !$0 { presenter.errorMessage = nil } }
            )) {
                Button("OK") {
                    presenter.errorMessage = nil
                }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ListToolbarView(
                        viewModel: ListToolbarViewModel(
                            tasks: presenter.tasks,
                            disableStatus: presenter.disableStatus
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    TaskListRouter.shared.makeTaskList()
}
