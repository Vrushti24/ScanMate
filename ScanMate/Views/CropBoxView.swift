//
//  CropBoxView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import SwiftUI

struct CropBoxView: View {
    @Binding var cropRect: CGRect
    let parentSize: CGSize

    let handleSize: CGFloat = 20

    var body: some View {
        ZStack {
            // Main crop outline
            Rectangle()
                .path(in: cropRect)
                .stroke(Color.white, lineWidth: 2)

            // Draggable handles
            ForEach(CropCorner.allCases, id: \.self) { corner in
                Circle()
                    .frame(width: handleSize, height: handleSize)
                    .position(position(for: corner))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCorner(corner, with: value.translation)
                            }
                    )
                    .foregroundColor(.white)
            }
        }
    }

    func position(for corner: CropCorner) -> CGPoint {
        switch corner {
        case .topLeft:
            return cropRect.origin
        case .topRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.minY)
        case .bottomLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.maxY)
        case .bottomRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        }
    }

    func updateCorner(_ corner: CropCorner, with translation: CGSize) {
        let minSize: CGFloat = 40
        var newRect = cropRect

        switch corner {
        case .topLeft:
            newRect.origin.x += translation.width
            newRect.origin.y += translation.height
            newRect.size.width -= translation.width
            newRect.size.height -= translation.height
        case .topRight:
            newRect.origin.y += translation.height
            newRect.size.width += translation.width
            newRect.size.height -= translation.height
        case .bottomLeft:
            newRect.origin.x += translation.width
            newRect.size.width -= translation.width
            newRect.size.height += translation.height
        case .bottomRight:
            newRect.size.width += translation.width
            newRect.size.height += translation.height
        }

        // Constraints
        newRect.size.width = max(minSize, newRect.size.width)
        newRect.size.height = max(minSize, newRect.size.height)
        newRect.origin.x = max(0, min(newRect.origin.x, parentSize.width - newRect.width))
        newRect.origin.y = max(0, min(newRect.origin.y, parentSize.height - newRect.height))

        cropRect = newRect
    }
}

