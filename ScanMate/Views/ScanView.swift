//
//  ScanView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUICore
import UIKit
import CloudKit
import SwiftUI
import PDFKit
import QuickLookThumbnailing

struct ScanView: View {
    // MARK: - Properties
    
    // Core Data
    @EnvironmentObject private var folderManager: FolderManager
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)], animation: .default)
    private var folders: FetchedResults<Folder>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)], animation: .default)
    private var allTags: FetchedResults<Tag>

    // Scan States
    @State private var showOptionSheet = false
    @State private var showCameraScanner = false
    @State private var showImagePicker = false
    @State private var showFilePicker = false
    @State private var showEditView = false
    @State private var showImageEditFlow = false
    @State private var showPDFEditFlow = false
    @State private var showUnsupportedAlert = false
    @State private var isLoading = false
    @State private var activeDocumentURL: URL?
    
    // Organization States
    @State private var selectedFolder: Folder?
    @State private var selectedTags = Set<Tag>()
    @State private var showFolderPicker = false
    @State private var showTagEditor = false
    @State private var newTagName = ""
    @State private var showSmartNamingOptions = false
    @State private var smartNamingTemplate = "Doc_$date_$counter"
    @State private var documentName = ""
    @State private var showNameInput = false
    
    // Document States
    @State private var selectedImage: UIImage?
    @State private var scannedImages: [UIImage] = []
    @State private var imagesToEdit: [UIImage] = []
    @State private var currentImageEditIndex = 0
    @State private var pdfPagesToEdit: [UIImage] = []
    @State private var currentPDFPageIndex = 0
    @State private var unsupportedFileMessage = ""
    
    // Sharing/Export
    @State private var showDocumentPicker = false
    @State private var documentToShare: URL?
    
    // OCR States
    @State private var showOCROptions = false
    @State private var ocrText = ""
    @State private var showOCRResult = false
    @State private var processingMode: ProcessingMode = .normal

    // MARK: - Main View
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContentView
                    .blur(radius: isLoading ? 3 : 0)
                
                if isLoading {
                    loadingView
                }
            }
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    clearButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    nameButton
                }
            }
            // Organization Sheets
            .sheet(isPresented: $showFolderPicker) {
                FolderPickerView(selectedFolder: $selectedFolder, onDismiss: {
                    // Handle dismiss action if needed
                    // For example:
                    showFolderPicker = false
                })
                .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showTagEditor) {
                TagEditorView(
                    selectedTags: $selectedTags,
                    newTagName: $newTagName,
                    allTags: Array(allTags),
                    onDismiss: {
                               showTagEditor = false
                           }
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showSmartNamingOptions) {
                SmartNamingOptionsView(
                    template: $smartNamingTemplate,
                    isPresented: $showSmartNamingOptions
                )
            }
            
            // Scanning/Import Sheets
            .confirmationDialog("Select Source", isPresented: $showOptionSheet, titleVisibility: .visible) {
                optionSheetButtons
            }
            .sheet(isPresented: $showCameraScanner) {
                DocumentScannerView { images in
                    handleCameraScannerResult(images: images)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerSheet { images in
                    handleImagePickerResult(images: images)
                }
            }
            .sheet(isPresented: $showFilePicker) {
                FilePickerSheet(allowedTypes: [.pdf, .image, .item]) { urls in
                    handleFilePickerResult(urls: urls)
                }
            }
            
            // Editing Sheets
            .sheet(isPresented: $showEditView) {
                editViewSheet
            }
            .sheet(isPresented: $showImageEditFlow) {
                MultiImageEditView(images: imagesToEdit) { editedImages in
                    handleImageEditResult(editedImages: editedImages)
                }
            }
            .sheet(isPresented: $showPDFEditFlow) {
                MultiImageEditView(images: pdfPagesToEdit) { editedImages in
                    handlePDFEditResult(editedImages: editedImages)
                }
            }
            
            // Sharing/Export
            .sheet(isPresented: $showDocumentPicker) {
                if let url = documentToShare {
                    DocumentPickerView(url: url) {
                        self.showDocumentPicker = false
                        self.documentToShare = nil
                    }
                }
            }
            
            // OCR Sheets
            .sheet(isPresented: $showOCROptions) {
                ocrOptionsSheet
            }
            .sheet(isPresented: $showOCRResult) {
                ocrResultSheet
            }
            
            // Alert
            .alert("Unsupported File", isPresented: $showUnsupportedAlert) {
                Button("OK", role: .cancel) {
                    cleanupTemporaryFiles()
                }
            } message: {
                Text(unsupportedFileMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mainContentView: some View {
        VStack {
            previewSection
            
            if showNameInput {
                VStack(spacing: 10) {
                    nameInputField
                    
                    Button("Save Document") {
                        saveDocument(images: scannedImages)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }
            
            organizationInfoSection
            
            Spacer()
            
            actionButtonsSection
        }
    }
    
    private var previewSection: some View {
        Group {
            if let preview = selectedImage {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            } else {
                ContentUnavailableView(
                    "No Document Selected",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Tap below to scan or import")
                )
            }
        }
    }
    
    private var nameInputField: some View {
        TextField("Document Name", text: $documentName)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
    }
    
    private var organizationInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let folder = selectedFolder {
                HStack {
                    Image(systemName: folder.icon ?? "folder")
                    Text(folder.name ?? "Unknown Folder")
                }
                .font(.subheadline)
            }
            
            if !selectedTags.isEmpty {
                TagListView(tags: Array(selectedTags))
            }
        }
        .padding(.horizontal)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button("Upload or Scan") {
                showOptionSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading)
            
            organizationButtons
        }
        .padding()
    }
    
    private var organizationButtons: some View {
        HStack {
            Button {
                showFolderPicker = true
            } label: {
                Label(
                    selectedFolder?.name ?? "Add to Folder",
                    systemImage: selectedFolder?.icon ?? "folder"
                )
            }
            .buttonStyle(.bordered)
            
            Button {
                showTagEditor = true
            } label: {
                Label("Tags", systemImage: "tag")
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var loadingView: some View {
        ProgressView("Processing...")
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var clearButton: some View {
        Button("Clear", systemImage: "trash") {
            resetState()
        }
        .disabled(selectedImage == nil)
    }
    
    private var nameButton: some View {
        Button("Name", systemImage: "pencil") {
            showNameInput.toggle()
        }
        .disabled(selectedImage == nil)
    }
    
    // MARK: - View Modifiers
   
    // MARK: - Sheet Content Helpers
    
    private var optionSheetButtons: some View {
        Group {
            Button("Scan with Camera") {
                processingMode = .normal
                showCameraScanner = true
            }
            Button("Import Images") {
                processingMode = .normal
                showImagePicker = true
            }
            Button("Import Files") {
                processingMode = .normal
                showFilePicker = true
            }
            Button("Extract Text (OCR)") {
                processingMode = .ocr
                showOCROptions = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var editViewSheet: some View {
        Group {
            if let image = selectedImage {
                EditView(inputImage: image) { edited in
                    self.selectedImage = edited
                    self.showEditView = false
                }
            }
        }
    }
    
    private var ocrOptionsSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select source for text extraction")
                    .font(.headline)
                    .padding(.top)
                
                Button(action: {
                    showOCROptions = false
                    showCameraScanner = true
                }) {
                    Label("From Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                
                Button(action: {
                    showOCROptions = false
                    showImagePicker = true
                }) {
                    Label("From Photos", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                
                Button(action: {
                    showOCROptions = false
                    showFilePicker = true
                }) {
                    Label("From Files", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
            }
            .navigationTitle("Extract Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showOCROptions = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var ocrResultSheet: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text(ocrText)
                        .padding()
                        .textSelection(.enabled)
                }
                
                Divider()
                
                HStack {
                    Button(action: {
                        UIPasteboard.general.string = ocrText
                    }) {
                        Label("Copy All", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        shareText(ocrText)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Extracted Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showOCRResult = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Result Handlers
    
    private func handleCameraScannerResult(images: [UIImage]) {
        if processingMode == .ocr {
            if let first = images.first {
                processImageForOCR(first)
            }
        } else {
            self.scannedImages = images
            if let first = images.first {
                self.selectedImage = first
                self.saveDocument(images: images) // Save all images, not just first
            }
        }
        processingMode = .normal
    }
    
    private func handleImagePickerResult(images: [UIImage]) {
        if processingMode == .ocr {
            if let first = images.first {
                processImageForOCR(first)
            }
        } else {
            if !images.isEmpty {
                self.imagesToEdit = Array(images.prefix(20))
                self.currentImageEditIndex = 0
                self.selectedImage = self.imagesToEdit.first
                self.showImageEditFlow = true
            }
        }
        processingMode = .normal
    }
    
    private func handleFilePickerResult(urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Create a safe temporary URL
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)
        
        do {
            // Clean up previous temp file if exists
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            // Copy to temp location
            try FileManager.default.copyItem(at: url, to: tempURL)
            
            DispatchQueue.main.async {
                if self.processingMode == .ocr {
                    self.processFileForOCR(url: tempURL)
                } else {
                    self.activeDocumentURL = tempURL
                    self.processSelectedFile(url: tempURL)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.showUnsupportedFile(message: "Failed to import file: \(error.localizedDescription)")
            }
        }
        
        self.processingMode = .normal
    }
    
    private func handleImageEditResult(editedImages: [UIImage]) {
        self.imagesToEdit = editedImages
        self.selectedImage = editedImages.first
        self.scannedImages = editedImages
        self.showImageEditFlow = false

        // 👉 Instead of saving immediately, ask for file name
        self.showNameInput = true
    }

    private func handlePDFEditResult(editedImages: [UIImage]) {
        self.pdfPagesToEdit = editedImages
        self.selectedImage = editedImages.first
        self.scannedImages = editedImages
        self.showPDFEditFlow = false
        cleanupTemporaryFiles()

        // 👉 Instead of saving immediately, ask for file name
        self.showNameInput = true
    }

    
    // MARK: - Document Management
    
    
    // Modify the saveDocument method to be more thread-safe:
    private func saveDocument(images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        isLoading = true
        
        let docName = documentName.isEmpty ? generateSmartName() : documentName
        let fileName = "\(docName).pdf"
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Create PDF data
                let pdfData = self.createPDF(from: images)
                
                // Save to persistent storage
                let folderURL = self.folderManager.folderURL(for: self.selectedFolder)
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                let fileURL = folderURL.appendingPathComponent(fileName)
                try pdfData.write(to: fileURL)
                
                // Create Core Data record
                let newDocument = Document(context: self.viewContext)
                newDocument.id = UUID()
                newDocument.name = docName
                newDocument.fileURL = fileName  // storing file name only, not full path
                newDocument.createdAt = Date()
                newDocument.folder = self.selectedFolder
                
                print(fileName)
                
                // Add tags
                for tag in self.selectedTags {
                    newDocument.addToTags(tag)
                }
                
                try self.viewContext.save()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.documentToShare = fileURL
                    self.showDocumentPicker = true
                    self.resetState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Save failed: \(error.localizedDescription)")
                }
            }
        }
    }


    private func saveExternalPDF(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let folderURL = documentsURL.appendingPathComponent(self.selectedFolder?.name ?? "Documents")
                let filename = url.deletingPathExtension().lastPathComponent
                let fileExtension = url.pathExtension
                
                // Ensure directory exists
                if !FileManager.default.fileExists(atPath: folderURL.path) {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                }
                
                let fileURL = folderURL.appendingPathComponent("\(filename).\(fileExtension)")
                
                // Remove existing file if it exists
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                
                // Copy the file
                try FileManager.default.copyItem(at: url, to: fileURL)
                
                // Create Core Data document
                let newDocument = Document(context: self.viewContext)
                newDocument.id = UUID()
                newDocument.name = filename
            
                let relativePath = fileURL.path.replacingOccurrences(of: documentsURL.path + "/", with: "")
                newDocument.fileURL = relativePath
                newDocument.createdAt = Date()
                
                // Set folder relationship
                if let folder = self.selectedFolder {
                    newDocument.folder = folder
                }
                
                // Add tags
                for tag in self.selectedTags {
                    newDocument.addToTags(tag)
                }
                
                try self.viewContext.save()
                
                DispatchQueue.main.async {
                    self.documentToShare = fileURL
                    self.showDocumentPicker = true
                    self.resetState()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error saving external file: \(error.localizedDescription)")
                }
            }
        }
    }

    
    private func generateSmartName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        
        let count = (try? viewContext.count(for: Document.fetchRequest())) ?? 0
        
        return smartNamingTemplate
            .replacingOccurrences(of: "$date", with: dateString)
            .replacingOccurrences(of: "$counter", with: "\(count + 1)")
    }
    
    // MARK: - File Processing
    
    private func processSelectedFile(url: URL) {
        let fileExtension = url.pathExtension.lowercased()
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            switch fileExtension {
            case "pdf":
                handlePDFFile(url: url)
            case "jpg", "jpeg", "png", "heic", "webp":
                handleImageFile(url: url)
            case "docx", "doc", "pptx", "ppt", "xlsx", "xls":
                handleOfficeDocument(url: url)
            case "txt", "rtf":
                handleTextFile(url: url)
            default:
                handleUnsupportedFile(url: url)
            }
        }
    }
    
    private func handlePDFFile(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let images = self.renderAllPagesFromPDF(url: url)
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard !images.isEmpty else {
                    self.showUnsupportedFile(message: "Could not extract pages from this PDF")
                    return
                }
                
                self.pdfPagesToEdit = images
                self.selectedImage = images.first
                self.showPDFEditFlow = true
                
                // Only save original if it's not temporary
                if !url.path.contains("tmp") {
                    self.saveExternalPDF(url: url)
                }
            }
        }
    }
    
    private func getDocumentsDirectory(for folder: Folder?) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if let folder = folder {
            return documentsURL.appendingPathComponent(folder.name ?? "Unnamed Folder")
        } else {
            return documentsURL.appendingPathComponent("Documents")
        }
    }
    
    private func handleImageFile(url: URL) {
        if let image = UIImage(contentsOfFile: url.path) {
            DispatchQueue.main.async {
                isLoading = false
                self.selectedImage = image
                self.showEditView = true
            }
        } else {
            DispatchQueue.main.async {
                isLoading = false
                showUnsupportedFile(message: "Could not load this image file")
            }
        }
    }
    
    private func handleOfficeDocument(url: URL) {
        isLoading = true
        
        ConvertAPI.convertToPDF(url) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let pdfURL):
                    // Process the converted PDF
                    self.handlePDFFile(url: pdfURL)
                    
                    // Clean up temporary file
                    try? FileManager.default.removeItem(at: pdfURL)
                    
                case .failure(let error):
                    self.showUnsupportedFile(message: "Conversion failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleTextFile(url: URL) {
        if let text = try? String(contentsOf: url, encoding: .utf8),
           let image = textToImage(text: text) {
            DispatchQueue.main.async {
                isLoading = false
                self.selectedImage = image
                self.showEditView = true
            }
        } else {
            DispatchQueue.main.async {
                isLoading = false
                showUnsupportedFile(message: "Could not display this text file")
            }
        }
    }
    
    private func handleUnsupportedFile(url: URL) {
        renderFileAsImage(url: url, highQuality: false) { image in
            DispatchQueue.main.async {
                isLoading = false
                if let image = image {
                    self.selectedImage = image
                    self.showEditView = true
                }
                self.showUnsupportedFile(message: "This file type (\(url.pathExtension)) is not supported")
            }
        }
    }
    
    // MARK: - OCR Processing
    
    private func processImageForOCR(_ image: UIImage) {
        isLoading = true
        OCRService.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let text):
                    self.ocrText = text
                    self.showOCRResult = true
                case .failure(let error):
                    self.showUnsupportedFile(message: "Text extraction failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func processFileForOCR(url: URL) {
        let fileExtension = url.pathExtension.lowercased()
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            switch fileExtension {
            case "pdf":
                let images = self.renderAllPagesFromPDF(url: url)
                self.processMultipleImagesForOCR(images: images)
                
            case "jpg", "jpeg", "png", "heic", "webp":
                if let image = UIImage(contentsOfFile: url.path) {
                    self.processImageForOCR(image)
                }
                
            case "docx", "doc", "pptx", "ppt", "xlsx", "xls":
                ConvertAPI.convertToPDF(url) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    switch result {
                    case .success(let pdfURL):
                        let images = self.renderAllPagesFromPDF(url: pdfURL)
                        self.processMultipleImagesForOCR(images: images)
                        try? FileManager.default.removeItem(at: pdfURL)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.showUnsupportedFile(message: "Conversion failed: \(error.localizedDescription)")
                        }
                    }
                }
                
            default:
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showUnsupportedFile(message: "File type not supported for text extraction")
                }
            }
        }
    }
    
    private func processMultipleImagesForOCR(images: [UIImage]) {
        var combinedText = ""
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            
            OCRService.recognizeText(from: image) { result in
                switch result {
                case .success(let text):
                    combinedText += "=== Page \(index + 1) ===\n\(text)\n\n"
                case .failure(let error):
                    print("OCR failed for page \(index + 1): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            if !combinedText.isEmpty {
                self.ocrText = combinedText
                self.showOCRResult = true
            } else {
                self.showUnsupportedFile(message: "No text could be extracted")
            }
        }
    }
    
    // MARK: - Conversion Utilities
    
    private func renderAllPagesFromPDF(url: URL) -> [UIImage] {
        guard let pdfDoc = PDFDocument(url: url) else { return [] }
        var images: [UIImage] = []
        
        for i in 0..<pdfDoc.pageCount {
            guard let page = pdfDoc.page(at: i) else { continue }
            
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            
            let image = renderer.image { ctx in
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                UIColor.white.set()
                ctx.fill(pageRect)
                page.draw(with: .mediaBox, to: ctx.cgContext)
                
                ctx.cgContext.restoreGState()
            }
            
            images.append(image)
        }
        return images
    }
    
    private func createPDF(from images: [UIImage]) -> Data {
        let pageSize = CGSize(width: 595, height: 842)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        return pdfRenderer.pdfData { context in
            for image in images {
                guard !image.size.width.isNaN, !image.size.height.isNaN else { continue }
                
                context.beginPage()
                
                let scale = min(pageSize.width / image.size.width, pageSize.height / image.size.height)
                let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                let origin = CGPoint(
                    x: (pageSize.width - scaledSize.width) / 2,
                    y: (pageSize.height - scaledSize.height) / 2
                )
                let rect = CGRect(origin: origin, size: scaledSize)
                
                image.draw(in: rect)
            }
        }
    }
    
    private func renderFileAsImage(url: URL, highQuality: Bool, completion: @escaping (UIImage?) -> Void) {
        let size = highQuality ? CGSize(width: 1200, height: 1600) : CGSize(width: 600, height: 800)
        let scale = UIScreen.main.scale
        
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .all
        )
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            completion(thumbnail?.uiImage)
        }
    }
    
    private func textToImage(text: String, width: CGFloat = 800, fontSize: CGFloat = 18) -> UIImage? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let textSize = NSString(string: text).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).size
        
        let renderer = UIGraphicsImageRenderer(size: textSize)
        
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: textSize))
            text.draw(in: CGRect(origin: .zero, size: textSize), withAttributes: attributes)
        }
    }
    
    // MARK: - Sharing
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanupTemporaryFiles() {
        guard let url = activeDocumentURL else { return }
        if url.pathExtension.lowercased() != "pdf" && url.path.contains("tmp") {
            try? FileManager.default.removeItem(at: url)
        }
        activeDocumentURL = nil
    }
    
    private func resetState() {
        selectedImage = nil
        scannedImages = []
        imagesToEdit = []
        pdfPagesToEdit = []
        documentName = ""
        showNameInput = false
        selectedTags.removeAll()
        activeDocumentURL = nil
    }
    
    private func showUnsupportedFile(message: String) {
        unsupportedFileMessage = message
        showUnsupportedAlert = true
    }
}
