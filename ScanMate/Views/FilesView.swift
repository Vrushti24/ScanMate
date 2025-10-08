//
//  FilesView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI
import PDFKit

struct FilesView: View {
    @EnvironmentObject private var folderManager: FolderManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    
    @FetchRequest(
        entity: Document.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.createdAt, ascending: false)]
    ) var allDocuments: FetchedResults<Document>
    
    var filteredFiles: [Document] {
        if searchText.isEmpty {
            return Array(allDocuments)
        }
        return allDocuments.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if filteredFiles.isEmpty {
                    ContentUnavailableView(
                        "No documents found",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text(searchText.isEmpty ?
                                         "Add documents using the Scan tab" :
                                         "No results for '\(searchText)'")
                    )
                } else {
                    List {
                        ForEach(groupedDocuments, id: \.key) { section in
                            Section(header: Text(section.key)) {
                                ForEach(section.value) { document in
                                    NavigationLink {
                                        DocumentDetailView(document: document)
                                    } label: {
                                        DocumentRow(document: document)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteDocument(document)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Files")
            .toolbar {
                EditButton()
                    .disabled(filteredFiles.isEmpty)
            }
        }
    }
    
    private var groupedDocuments: [(key: String, value: [Document])] {
        let grouped = Dictionary(grouping: filteredFiles) { document in
            document.folder?.name ?? "Uncategorized"
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    private func deleteDocument(_ document: Document) {
        // Get the correct file URL
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderName = document.folder?.name ?? ""
        let fileURL = documentsURL
            .appendingPathComponent(folderName)
            .appendingPathComponent(document.fileURL ?? "")
        
        // Delete the physical file
        try? FileManager.default.removeItem(at: fileURL)
        
        // Delete from Core Data
        viewContext.delete(document)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
        }
    }
}

// MARK: - Subviews
private struct DocumentDetailView: View {
    let document: Document
    @EnvironmentObject private var folderManager: FolderManager
    
    var body: some View {
        Group {
            let fileURL = folderManager.fileURL(for: document)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                PDFViewerScreen(fileURL: fileURL)
            } else {
                fileNotFoundView
            }
        }
        .navigationTitle(document.name ?? "Document")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                let fileURL = folderManager.fileURL(for: document)
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    ShareLink(item: fileURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var fileNotFoundView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("File not found")
                .font(.title2)
            Text("The document file could not be located")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
//private struct DocumentRow: View {
//    let document: Document
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "doc.fill")
//                .foregroundColor(.blue)
//            VStack(alignment: .leading) {
//                Text(document.name ?? "Untitled Document")
//                    .font(.headline)
//                Text(document.createdAt?.formatted() ?? "")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}

private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search files...", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
    }
}
