//
//  ActionButton.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/22/25.
//

import SwiftUICore
import SwiftUI


struct ActionIconButton: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
