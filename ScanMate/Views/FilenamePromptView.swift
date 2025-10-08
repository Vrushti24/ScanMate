//
//  FilenamePromptView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/24/25.
//

import SwiftUICore
import SwiftUI


struct FilenamePromptView: View {
    @Binding var isPresented: Bool
    @Binding var filename: String
    var onSave: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter Filename")
                    .font(.headline)
                TextField("File name", text: $filename)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 40)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = filename.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty else { return }
                        onSave(trimmedName)
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
