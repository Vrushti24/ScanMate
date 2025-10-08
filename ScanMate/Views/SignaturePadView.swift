//
//  SignaturePadView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import SwiftUICore
import UIKit
import SwiftUI


struct SignaturePadView: View {
    @State private var currentDrawing = Drawing()
    @State private var drawings = [Drawing]()
    @State private var color: Color = .black
    @State private var lineWidth: CGFloat = 2.0 // Thinner default for signatures
    private let canvasSize = CGSize(width: 300, height: 150) // Optimal signature size
    
    var onSave: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.white
                    
                    // Completed signatures
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
                    Button("Clear") {
                        drawings.removeAll()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    ColorPicker("", selection: $color)
                        .frame(width: 100)
                    
                    Slider(value: $lineWidth, in: 1...5) { // Smaller range for signatures
                        Text("Width")
                    }
                    .frame(width: 100)
                }
                .padding()
            }
            .navigationTitle("Add Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let signature = generateSignatureImage()
                        onSave(signature)
                    }
                }
            }
        }
    }
    
    private func generateSignatureImage() -> UIImage {
           let renderer = UIGraphicsImageRenderer(size: canvasSize)
           let image = renderer.image { ctx in
               // White background
               UIColor.white.setFill()
               ctx.fill(CGRect(origin: .zero, size: canvasSize))
               
               // Draw all signature strokes
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
