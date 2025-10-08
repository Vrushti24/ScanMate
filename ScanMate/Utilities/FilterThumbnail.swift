//
//  FilterThumbnail.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import SwiftUI

struct FilterThumbnail: View {
    let name: String
    let image: UIImage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Button(action: onTap) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            }

            Text(name)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}
