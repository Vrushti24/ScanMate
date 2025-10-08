//
//  ToolbarButton.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import SwiftUI

struct ToolbarButton: View {
    let icon: String
    let label: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}
