//
//  Drawing.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import Foundation
import UIKit
import SwiftUICore


struct Drawing: Identifiable {
    let id = UUID()
    var points: [CGPoint] = []
    var color: Color = .black
    var lineWidth: CGFloat = 3.0
    
    init(points: [CGPoint] = [], color: Color = .black, lineWidth: CGFloat = 3.0) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var path: UIBezierPath {
        let path = UIBezierPath()
        guard !points.isEmpty else { return path }
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
