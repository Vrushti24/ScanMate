//
//  DocumentPreviewView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore
import UIKit
import SwiftUI


struct DocumentPreviewView: View {
    let pages: [UIImage]
    var onConfirm: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPageIndex = 0
    
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Text(pages.count > 1 ? "Page \(currentPageIndex + 1) of \(pages.count)" : "Preview")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    onConfirm()
                }
            }
            .padding()
            
            // Page Display
            Image(uiImage: pages[currentPageIndex])
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
                .padding()
            
            // Navigation Controls (only show if multiple pages)
            if pages.count > 1 {
                HStack {
                    Button(action: previousPage) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding()
                    }
                    .disabled(currentPageIndex == 0)
                    
                    Spacer()
                    
                    Button(action: nextPage) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .padding()
                    }
                    .disabled(currentPageIndex == pages.count - 1)
                }
                .padding()
            }
        }
    }
    
    private func nextPage() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
        }
    }
    
    private func previousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}
