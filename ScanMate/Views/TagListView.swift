//
//  TagListView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//

import SwiftUICore
import SwiftUI


struct TagListView: View {
    var tags: [Tag]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(tag.color ?? "red"))
                            .frame(width: 8, height: 8)
                        Text(tag.name ?? "Unknown")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }
        }
    }
}
