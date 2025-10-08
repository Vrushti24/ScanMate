//
//  DrawingPad.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore
import SwiftUI

struct DrawingPad: View {
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    let canvasSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            // Draw current in-progress signature
            if !currentDrawing.points.isEmpty {
                var path = Path()
                path.addLines(currentDrawing.points)
                context.stroke(
                    path,
                    with: .color(currentDrawing.color),
                    lineWidth: currentDrawing.lineWidth
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    if currentDrawing.points.isEmpty {
                        currentDrawing = Drawing(
                            points: [point],
                            color: color,
                            lineWidth: lineWidth
                        )
                    } else {
                        currentDrawing.points.append(point)
                    }
                }
                .onEnded { _ in
                    if !currentDrawing.points.isEmpty {
                        drawings.append(currentDrawing)
                        currentDrawing = Drawing()
                    }
                }
        )
    }
}
