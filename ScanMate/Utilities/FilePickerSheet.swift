//
//  FilePickerSheet.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/22/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerSheet: UIViewControllerRepresentable {
    var allowedTypes: [UTType]
    var onFilesPicked: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerSheet

        init(_ parent: FilePickerSheet) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onFilesPicked(urls)
        }
    }
}
