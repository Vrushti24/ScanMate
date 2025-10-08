//
//  FolderManager.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//


import CoreData
import SwiftUI
import UniformTypeIdentifiers

class FolderManager: ObservableObject {
    // MARK: - Published Properties
    @Published var folders: [Folder] = []
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var error: FolderManagerError?
    
    let viewContext: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchAllData()
    }
    
    // MARK: - File System Helpers
    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func folderURL(for folder: Folder?) -> URL {
        let baseURL = documentsDirectory()
        guard let folder = folder else { return baseURL.appendingPathComponent("Documents") }
        return baseURL.appendingPathComponent(folder.name ?? "Unnamed Folder")
    }
    
    func fileURL(for document: Document) -> URL {
        let folderURL = folderURL(for: document.folder)
        return folderURL.appendingPathComponent(document.fileURL ?? "")
    }
    
    // MARK: - Data Fetching
    func fetchAllData() {
        fetchFolders()
        fetchDocuments()
    }
    
    func fetchFolders() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.name, ascending: true)]
        
        do {
            folders = try viewContext.fetch(request)
        } catch {
            handleError(.fetchError("Failed to fetch folders: \(error.localizedDescription)"))
        }
    }
    
    func fetchDocuments() {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.createdAt, ascending: false)]
        
        do {
            documents = try viewContext.fetch(request)
        } catch {
            handleError(.fetchError("Failed to fetch documents: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - Folder Operations
    func addFolder(name: String, icon: String = "folder") {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            handleError(.validationError("Folder name cannot be empty"))
            return
        }
        
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.name = name
        newFolder.icon = icon
        newFolder.createdAt = Date()
        
        do {
            try createDirectoryForFolder(name: name)
            saveContext()
        } catch {
            handleError(.fileOperationError("Failed to create folder: \(error.localizedDescription)"))
            viewContext.delete(newFolder)
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        // First delete all documents in the folder
        if let documents = folder.documents as? Set<Document> {
            for document in documents {
                deleteDocument(document, skipContextSave: true)
            }
        }
        
        do {
            try deleteDirectoryForFolder(folder)
            viewContext.delete(folder)
            saveContext()
        } catch {
            handleError(.fileOperationError("Failed to delete folder: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - Document Operations
    func addDocument(name: String, fileURL: URL, to folder: Folder?) -> Document? {
        isLoading = true
        defer { isLoading = false }
        
        let fileName = name.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : name
        let fileExtension = fileURL.pathExtension.lowercased() == "pdf" ? "pdf" : "pdf"
        let destinationFileName = "\(fileName).\(fileExtension)"
        
        do {
            let folderURL = folderURL(for: folder)
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            let destinationURL = folderURL.appendingPathComponent(destinationFileName)
            
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy or convert the file
            if fileExtension == "pdf" {
                try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            } else {
                try convertToPDFAndSave(sourceURL: fileURL, destinationURL: destinationURL)
            }
            
            // Create document entity
            let newDocument = Document(context: viewContext)
            newDocument.id = UUID()
            newDocument.name = fileName
            newDocument.fileURL = destinationFileName // Store only filename
            newDocument.createdAt = Date()
            newDocument.folder = folder
            
            saveContext()
            return newDocument
            
        } catch {
            handleError(.fileOperationError("Failed to add document: \(error.localizedDescription)"))
            return nil
        }
    }
    
    func deleteDocument(_ document: Document, skipContextSave: Bool = false) {
        do {
            try deletePhysicalFile(for: document)
            viewContext.delete(document)
            if !skipContextSave {
                saveContext()
            }
        } catch {
            handleError(.fileOperationError("Failed to delete document: \(error.localizedDescription)"))
        }
    }
    
    func moveDocument(_ document: Document, to folder: Folder?) {
        guard let fileName = document.fileURL else {
            handleError(.fileOperationError("Document has no file name"))
            return
        }
        
        let sourceURL = fileURL(for: document)
        let destinationURL = folderURL(for: folder).appendingPathComponent(fileName)
        
        do {
            try FileManager.default.createDirectory(at: destinationURL.deletingLastPathComponent(),
                                                  withIntermediateDirectories: true)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
            
            document.folder = folder
            saveContext()
            
        } catch {
            handleError(.fileOperationError("Failed to move document: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - File System Operations
    private func createDirectoryForFolder(name: String) throws {
        let folderURL = documentsDirectory().appendingPathComponent(name)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    private func deleteDirectoryForFolder(_ folder: Folder) throws {
        let folderURL = folderURL(for: folder)
        if FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.removeItem(at: folderURL)
        }
    }
    
    private func deletePhysicalFile(for document: Document) throws {
        let fileURL = fileURL(for: document)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    private func convertToPDFAndSave(sourceURL: URL, destinationURL: URL) throws {
        // Implement your actual PDF conversion logic here
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
    
    // MARK: - Core Data Save
    private func saveContext() {
        do {
            try viewContext.save()
            fetchAllData()
        } catch {
            handleError(.coreDataError("Failed to save context: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: FolderManagerError) {
        DispatchQueue.main.async {
            self.error = error
            print("FolderManager Error: \(error.localizedDescription)")
        }
    }
}


