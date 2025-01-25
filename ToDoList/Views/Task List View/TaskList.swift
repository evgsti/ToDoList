//
//  ContentView.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import SwiftUI

struct TaskList: View {
    @StateObject private var presenter: TaskListPresenter
    
    @State private var showShareSheet = false
    @State private var showEditView = false
    @State private var selectedTask: TaskEntity?
    
    init(presenter: TaskListPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(presenter.filteredTasks) { task in
                    TaskRow(
                        viewModel: TaskRowViewModel(task: task),
                        checkAction: { presenter.toggleTaskCompletion(task: task) },
                        deleteAction: { presenter.deleteTask(task: task) }
                    )
                    .onTapGesture {
                        selectedTask = task
                        showEditView = true
                    }
                    .contextMenu {
                        TaskRowContextMenuView(
                            edit: {
                                selectedTask = task
                                showEditView = true
                            },
                            share: {
                                selectedTask = task
                                showShareSheet = true
                            },
                            delete: {
                                withAnimation {
                                    presenter.deleteTask(task: task)
                                }
                            }
                        )
                    } preview: {
                        TaskRowPreviewView(viewModel: TaskRowViewModel(task: task))
                    }
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
            .navigationDestination(isPresented: $showEditView) {
                if let task = selectedTask {
                    TaskListRouter.shared.makeTaskCreateAndUpdate(task: task)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let task = selectedTask {
                    ShareSheetView(text: TaskRowViewModel(task: task).shareText())
                        .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    TaskListRouter.shared.makeTaskList()
}
