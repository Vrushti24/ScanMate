//
//  TextElement.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import Foundation
import SwiftUICore


struct TextElement: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    var position: CGPoint
    let fontSize: CGFloat
}
