//
//  TextInputView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore
import SwiftUI


struct TextInputView: View {
    @Binding var text: String
    var onDone: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
            }
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDone()
                    }
                }
            }
        }
    }
}
