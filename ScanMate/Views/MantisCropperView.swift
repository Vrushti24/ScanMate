//
//  MantisCropperView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import SwiftUI
import Mantis

struct MantisCropperView: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var image: UIImage?
    var onCrop: (UIImage) -> Void

    @State private var transformation: Transformation?
    @State private var cropInfo: CropInfo?

    var body: some View {
        NavigationView {
            if image != nil {
                ImageCropperView(
                    image: $image,
                    transformation: $transformation,
                    cropInfo: $cropInfo
                )
                .onDisappear {
                    if let finalImage = image {
                        onCrop(finalImage)
                    }
                }
                .navigationBarTitle("Crop", displayMode: .inline)
            } else {
                Text("No image selected")
                    .onAppear {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
    }
}
