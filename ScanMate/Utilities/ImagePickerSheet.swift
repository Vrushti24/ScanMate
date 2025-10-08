//
//  ImagePickerSheet.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/22/25.
//

import SwiftUI
import PhotosUI

struct ImagePickerSheet: UIViewControllerRepresentable {
    var onImagesPicked: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 20
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerSheet

        init(_ parent: ImagePickerSheet) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let itemProviders = results.map(\.itemProvider)
            var images: [UIImage] = []

            let group = DispatchGroup()

            for provider in itemProviders where provider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.onImagesPicked(images)
            }
        }
    }
}
