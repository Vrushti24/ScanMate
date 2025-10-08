//
//  DrawingShape.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore


struct DrawingShape: Shape {
    let drawing: Drawing
    let imageSize: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !drawing.points.isEmpty else { return path }
        
        // Calculate scaling to maintain proportions
        let scale = min(
            rect.width / imageSize.width,
            rect.height / imageSize.height
        )
        
        let offsetX = (rect.width - (imageSize.width * scale)) / 2
        let offsetY = (rect.height - (imageSize.height * scale)) / 2
        
        path.move(to: CGPoint(
            x: (drawing.points[0].x * scale) + offsetX,
            y: (drawing.points[0].y * scale) + offsetY
        ))
        
        for point in drawing.points.dropFirst() {
            path.addLine(to: CGPoint(
                x: (point.x * scale) + offsetX,
                y: (point.y * scale) + offsetY
            ))
        }
        
        return path
    }
}
