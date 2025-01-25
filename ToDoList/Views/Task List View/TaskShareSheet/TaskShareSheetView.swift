//
//  TaskShareSheetView.swift.swift
//  ToDoList
//
//  Created by Евгений on 25.01.2025.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
