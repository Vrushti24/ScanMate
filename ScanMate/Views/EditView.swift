//
//  EditView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Mantis

struct EditView: View {
    let inputImage: UIImage
    var onFinished: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var editedImage: UIImage?
    @State private var selectedFilter: String = "Original"
    @State private var selectedTool: String = ""
    @State private var showCropView = false
    
    // Drawing/Signature states
    @State private var showTextInput = false
    @State private var textElements: [TextElement] = []
    @State private var currentText: String = ""
    @State private var isComparing = false

    @State private var drawings: [Drawing] = []
    @State private var currentDrawing = Drawing()
    @State private var isDrawing = false
    @State private var color: Color = .black
    @State private var lineWidth: CGFloat = 3.0
    @State private var showFinalPreview = false
    @State private var previewImageSize: CGSize = .zero
    
    let context = CIContext()

    var displayImage: UIImage {
        editedImage ?? inputImage
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Text("Edit")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    previewImageSize = CGSize(
                        width: displayImage.size.width,
                        height: displayImage.size.height * 1.5 // Increase height by 50%
                    )
                    let finalImage = generateFinalImage()
                    onFinished(finalImage)
                    showFinalPreview = true
                }
            }
            .padding()
            
            // Image with overlays
            ZStack {
                // Display either edited or original image
                if isComparing {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 600)
                        .padding(.horizontal)
                        .opacity(0.5)
                }
                
                Image(uiImage: displayImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 600)
                    .padding(.horizontal)
                    .opacity(isComparing ? 0.5 : 1.0)
                
                // Permanent drawings overlay
                ForEach(drawings) { drawing in
                    DrawingShape(drawing: drawing, imageSize: displayImage.size)
                        .stroke(drawing.color, lineWidth: drawing.lineWidth)
                }
                
                // Current drawing overlay (visible during active drawing)
                if isDrawing {
                    DrawingShape(drawing: currentDrawing, imageSize: displayImage.size)
                        .stroke(currentDrawing.color, lineWidth: currentDrawing.lineWidth)
                }
                
                // Text elements overlay
                ForEach(textElements) { textElement in
                    Text(textElement.text)
                        .font(.system(size: textElement.fontSize))
                        .foregroundColor(textElement.color)
                        .position(textElement.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if let index = textElements.firstIndex(where: { $0.id == textElement.id }) {
                                        textElements[index].position = value.location
                                    }
                                }
                        )
                }
            }
            .frame(maxHeight: 600)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if selectedTool == "Draw" || selectedTool == "Signature" {
                            if !isDrawing {
                                isDrawing = true
                                currentDrawing = Drawing(
                                    color: color,
                                    lineWidth: selectedTool == "Signature" ? 2.0 : lineWidth
                                )
                            }
                            currentDrawing.points.append(value.location)
                        }
                    }
                    .onEnded { _ in
                        if isDrawing {
                            drawings.append(currentDrawing)
                            isDrawing = false
                        }
                    }
            )

            Spacer()

            // Filter Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterThumbnail(name: "Original", image: inputImage, isSelected: selectedFilter == "Original") {
                        selectedFilter = "Original"
                        editedImage = nil
                    }
                    FilterThumbnail(name: "Grayscale", image: applyGrayscaleFilter(to: displayImage), isSelected: selectedFilter == "Grayscale") {
                        selectedFilter = "Grayscale"
                        editedImage = applyGrayscaleFilter(to: displayImage)
                    }
                    FilterThumbnail(name: "B & W", image: applyBlackWhiteFilter(to: displayImage), isSelected: selectedFilter == "B & W") {
                        selectedFilter = "B & W"
                        editedImage = applyBlackWhiteFilter(to: displayImage)
                    }
                    FilterThumbnail(name: "Boost", image: applyColorBoostFilter(to: displayImage), isSelected: selectedFilter == "Boost") {
                        selectedFilter = "Boost"
                        editedImage = applyColorBoostFilter(to: displayImage)
                    }
                    FilterThumbnail(name: "Lighten", image: applyLightenFilter(to: displayImage), isSelected: selectedFilter == "Lighten") {
                        selectedFilter = "Lighten"
                        editedImage = applyLightenFilter(to: displayImage)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)

            Divider()

            // Toolbar
            if selectedTool == "Draw" || selectedTool == "Signature" {
                // Drawing tools toolbar
                HStack {
                    ColorPicker("", selection: $color)
                        .frame(width: 50)
                    
                    if selectedTool == "Draw" {
                        Slider(value: $lineWidth, in: 1...10) {
                            Text("Width")
                        }
                        .frame(width: 100)
                    }
                    
                    Button {
                        showTextInput = true
                    } label: {
                        Image(systemName: "textformat")
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        drawings.removeAll()
                        textElements.removeAll()
                    } label: {
                        Image(systemName: "trash")
                            .padding(8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        selectedTool = ""
                    }
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            } else {
                // Main tools toolbar
                HStack(spacing: 30) {
                    ToolbarButton(icon: "crop", label: "Crop", isSelected: selectedTool == "Crop") {
                        selectedTool = "Crop"
                        showCropView = true
                    }
                    
                    ToolbarButton(icon: "wand.and.stars", label: "Enhance", isSelected: selectedTool == "Enhance") {
                        selectedTool = "Enhance"
                        editedImage = applyEnhanceFilter(to: displayImage)
                        selectedFilter = "Enhance"
                    }
                    
                    ToolbarButton(icon: "arrow.triangle.2.circlepath", label: "Rotate", isSelected: selectedTool == "Rotate") {
                        selectedTool = "Rotate"
                        if let rotated = rotateImage(displayImage) {
                            editedImage = rotated
                        }
                        selectedFilter = "Rotated"
                    }
                    
                    ToolbarButton(icon: "pencil.tip", label: "Draw", isSelected: selectedTool == "Draw") {
                        selectedTool = "Draw"
                        color = .red
                        lineWidth = 3.0
                    }
                    
                    ToolbarButton(icon: "signature", label: "Sign", isSelected: selectedTool == "Signature") {
                        selectedTool = "Signature"
                        color = .black
                    }
                    
                    ToolbarButton(icon: "rectangle.2.swap", label: "Compare", isSelected: isComparing) {
                        isComparing.toggle()
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showCropView) {
            NavigationView {
                MantisCropperView(image: Binding<UIImage?>(
                    get: { self.editedImage ?? self.inputImage },
                    set: { self.editedImage = $0 }
                )) { cropped in
                    self.editedImage = cropped
                    self.selectedTool = "Crop"
                    self.selectedFilter = "Cropped"
                }
            }
        }
        .sheet(isPresented: $showTextInput) {
            TextInputView(text: $currentText) {
                if !currentText.isEmpty {
                    textElements.append(TextElement(
                        text: currentText,
                        color: color,
                        position: CGPoint(x: UIScreen.main.bounds.width/2, y: 300),
                        fontSize: 24
                    ))
                    currentText = ""
                }
                showTextInput = false
            }
        }
    }

    // MARK: - Image Generation
    func generateFinalImage() -> UIImage {
        let outputSize = previewImageSize
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        
        return renderer.image { ctx in
            // Draw white background
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: outputSize))
            
            // Calculate centered position for original image
            let imageRect = CGRect(
                x: (outputSize.width - displayImage.size.width) / 2,
                y: 0, // Align to top
                width: displayImage.size.width,
                height: displayImage.size.height
            )
            
            // Draw the base image
            displayImage.draw(in: imageRect)
            
            // Setup drawing context
            let cgContext = ctx.cgContext
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            
            // Draw all completed drawings
            for drawing in drawings {
                if !drawing.points.isEmpty {
                    cgContext.setStrokeColor(drawing.color.cgColor!)
                    cgContext.setLineWidth(drawing.lineWidth)
                    
                    // Adjust points for the centered image
                    cgContext.move(to: CGPoint(
                        x: drawing.points[0].x + imageRect.origin.x,
                        y: drawing.points[0].y + imageRect.origin.y
                    ))
                    
                    for point in drawing.points.dropFirst() {
                        cgContext.addLine(to: CGPoint(
                            x: point.x + imageRect.origin.x,
                            y: point.y + imageRect.origin.y
                        ))
                    }
                    cgContext.strokePath()
                }
            }
            
            // Draw all text elements
            for textElement in textElements {
                let text = textElement.text as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: textElement.fontSize),
                    .foregroundColor: UIColor(textElement.color)
                ]
                text.draw(at: CGPoint(
                    x: textElement.position.x + imageRect.origin.x,
                    y: textElement.position.y + imageRect.origin.y
                ), withAttributes: attributes)
            }
        }
    }
    
    // MARK: - Filter Functions
    private func applyGrayscaleFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.photoEffectMono()
        filter.inputImage = ciImage
        return render(from: filter.outputImage!)
    }

    private func applyBlackWhiteFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 0
        filter.contrast = 1.5
        return render(from: filter.outputImage!)
    }

    private func applyColorBoostFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 2.0
        filter.brightness = 0.05
        filter.contrast = 1.2
        return render(from: filter.outputImage!)
    }

    private func applyLightenFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = ciImage
        filter.ev = 1.0
        return render(from: filter.outputImage!)
    }

    private func applyEnhanceFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = 0.1
        filter.saturation = 1.4
        filter.contrast = 1.2
        return render(from: filter.outputImage!)
    }

    private func rotateImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let currentOrientation = image.imageOrientation
        let nextOrientation: UIImage.Orientation
        
        switch currentOrientation {
        case .up: nextOrientation = .right
        case .right: nextOrientation = .down
        case .down: nextOrientation = .left
        case .left: nextOrientation = .up
        default: nextOrientation = .right
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: nextOrientation)
    }

    private func render(from ciImage: CIImage) -> UIImage {
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage, scale: displayImage.scale, orientation: displayImage.imageOrientation)
        }
        return displayImage
    }
}
