//
//  DocumentPickerView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import SwiftUI
import PhotosUI

struct DocumentPickerView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Verify file exists before creating the picker
        guard FileManager.default.fileExists(atPath: url.path) else {
            // Handle error case - perhaps show an alert
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "The document could not be found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true)
                }
                
                onDismiss()
            }
            
            // Return an empty picker that will immediately dismiss
            return UIDocumentPickerViewController(forExporting: [])
        }
        
        let picker = UIDocumentPickerViewController(forExporting: [url])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onDismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDismiss()
        }
    }
}
