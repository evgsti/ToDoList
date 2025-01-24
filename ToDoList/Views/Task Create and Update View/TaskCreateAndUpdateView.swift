//
//  TaskCreateAndUpdateView.swift
//  ToDoList
//
//  Created by Евгений on 23.01.2025.
//

import SwiftUI

struct TaskCreateAndUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var presenter: TaskCaUPresenter
    
    init(presenter: TaskCaUPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Название", text: $presenter.title,  axis: .vertical)
                .lineLimit(3)
                .font(.system(size: 34, weight: .bold))
                .padding(.bottom, 8)
                .foregroundStyle(.primary)
            
            Text(presenter.formattedDate)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            
            TextField("Описание", text: $presenter.description, axis: .vertical)
                .font(.system(size: 16, weight: .semibold))
                .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if presenter.task == nil {
                        if !presenter.title.isEmpty || !presenter.description.isEmpty {
                            presenter.saveTask {
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    } else {
                        if presenter.hasChanges {
                            presenter.saveTask {
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                    Text("Назад")
                }
            }
            
            if presenter.task == nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

#Preview {
    let task = TaskEntity.previewInstance(
        title: "Задача",
        description: "Описание задачи",
        createdAt: Date(),
        isCompleted: false
    )
    
    let storageManager = PersistenceController.preview
    let interactor = TaskCaUInteractor(storageManager: storageManager)
    let presenter = TaskCaUPresenter(interactor: interactor, task: task)
    
    TaskCreateAndUpdateView(presenter: presenter)
}
