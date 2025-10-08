//
//  SmartNamingOptionsView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//

import SwiftUICore
import SwiftUI

struct SmartNamingOptionsView: View {
    @Binding var template: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template Variables") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("$date - Current date (YYYYMMDD)")
                        Text("$counter - Document count")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Section("Current Template") {
                    TextField("Template", text: $template)
                }
            }
            .navigationTitle("Smart Naming")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
