//
//  MultiImageEditView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import UIKit
import SwiftUICore
import SwiftUI


struct MultiImageEditView: View {
    let images: [UIImage]
    var onFinished: ([UIImage]) -> Void
    
    @State private var editedImages: [UIImage]
    @State private var selectedIndex: Int = 0
    @State private var showSingleEditView = false
    
    init(images: [UIImage], onFinished: @escaping ([UIImage]) -> Void) {
        self.images = images
        self.onFinished = onFinished
        self._editedImages = State(initialValue: images)
    }
    
    var body: some View {
        VStack {
            // Top navigation bar
            HStack {
                Button("Cancel") {
                    onFinished(images) // Return original images
                }
                Spacer()
                Text("Edit \(selectedIndex + 1) of \(images.count)")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    print("✅ Done Editing — Final image count: \(editedImages.count)")
                    onFinished(editedImages)
                }
            }
            .padding()
            
            // Main image display (Adjust this)
            Image(uiImage: editedImages[selectedIndex])
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 450)  // Explicit, reasonable height
                .padding()
            
            Spacer()
            
            // Thumbnail scroll view (Reduce height here)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<editedImages.count, id: \.self) { index in
                        Image(uiImage: editedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 80)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100) // Smaller thumbnail height (100-120 recommended)
            
            // Edit options
            Button("Edit This Page") {
                showSingleEditView = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
        }
        .sheet(isPresented: $showSingleEditView) {
            EditView(inputImage: editedImages[selectedIndex]) { editedImage in
                editedImages[selectedIndex] = editedImage
                showSingleEditView = false
            }
        }
    }
}
