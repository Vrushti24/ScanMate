//
//  DrawingPadView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore
import UIKit
import SwiftUI


struct DrawingPadView: View {
    @State private var currentDrawing = Drawing()
    @State private var drawings = [Drawing]()
    @State private var color: Color = .black
    @State private var lineWidth: CGFloat = 3.0
    @State private var selectedTool: String = "pen"
    private let canvasSize = CGSize(width: 400, height: 400)
    
    var onSave: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.white
                    
                    // Completed drawings
                    ForEach(drawings) { drawing in
                        DrawingShape(drawing: drawing, imageSize: canvasSize)
                            .stroke(drawing.color, lineWidth: drawing.lineWidth)
                    }
                    
                    // Active drawing pad
                    DrawingPad(
                        currentDrawing: $currentDrawing,
                        drawings: $drawings,
                        color: $color,
                        lineWidth: $lineWidth,
                        canvasSize: canvasSize
                    )
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                
                HStack {
                    Button(action: { selectedTool = "pen" }) {
                        Image(systemName: "pencil")
                            .padding()
                            .background(selectedTool == "pen" ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { selectedTool = "text" }) {
                        Image(systemName: "textformat")
                            .padding()
                            .background(selectedTool == "text" ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    ColorPicker("", selection: $color)
                        .frame(width: 50)
                    
                    Slider(value: $lineWidth, in: 1...10) {
                        Text("Width")
                    }
                    .frame(width: 100)
                    
                    Button("Clear") {
                        drawings.removeAll()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Drawing Tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let drawing = generateDrawingImage()
                        onSave(drawing)
                    }
                }
            }
        }
    }
    
    private func generateDrawingImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { ctx in
            // White background
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Draw all strokes
            let cgContext = ctx.cgContext
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            
            for drawing in drawings {
                if !drawing.points.isEmpty {
                    cgContext.setStrokeColor(drawing.color.cgColor!)
                    cgContext.setLineWidth(drawing.lineWidth)
                    cgContext.move(to: drawing.points[0])
                    
                    for point in drawing.points.dropFirst() {
                        cgContext.addLine(to: point)
                    }
                    cgContext.strokePath()
                }
            }
        }
        return image
    }
}
