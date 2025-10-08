//
//  FoldersView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//

import SwiftUI
import CoreData


struct FoldersView: View {
    @EnvironmentObject private var folderManager: FolderManager
    @State private var showingAddFolder = false
    @State private var newFolderName = ""
    @State private var newFolderIcon = "folder"
    
    let icons = ["folder", "briefcase", "house", "cart", "book", "doc.text", "photo"]
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 20)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(folderManager.folders) { folder in
                        NavigationLink {
                            FolderFilesView(folder: folder)
                                .environmentObject(folderManager)
                        } label: {
                            FolderGridItem(folder: folder)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                folderManager.deleteFolder(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFolder = true
                        newFolderName = ""
                        newFolderIcon = "folder"
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                NewFolderSheet(
                    isPresented: $showingAddFolder,
                    newFolderName: $newFolderName,
                    newFolderIcon: $newFolderIcon,
                    icons: icons,
                    folderManager: folderManager
                )
            }
        }
    }
}

struct FolderGridItem: View {
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: folder.icon ?? "folder")
                .font(.system(size: 32))
                .foregroundColor(.blue)
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(folder.name ?? "Unnamed Folder")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(folder.documentCount()) item\(folder.documentCount() == 1 ? "" : "s")")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 120, height: 120)
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

}

struct FolderFilesView: View {
    @ObservedObject var folder: Folder
    @EnvironmentObject private var folderManager: FolderManager
    @State private var showingFileImporter = false
   
        
    @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest var documents: FetchedResults<Document>
        
        init(folder: Folder) {
            self.folder = folder
            _documents = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \Document.createdAt, ascending: false)],
                predicate: NSPredicate(format: "folder == %@", folder)
            )
        }
    
    var body: some View {
        Group {
            if documents.isEmpty {
                ContentUnavailableView(
                    "No Files",
                    systemImage: "folder",
                    description: Text("Add files to this folder")
                )
            } else {
                List {
                    ForEach(documents) { document in
                        DocumentRow(document: document)
                    }
                    .onDelete(perform: deleteDocuments)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(folder.name ?? "Folder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingFileImporter = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        offsets.forEach { index in
            if index < documents.count {
                let document = documents[index]
                folderManager.deleteDocument(document)
            }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let fileName = url.deletingPathExtension().lastPathComponent
            folderManager.addDocument(name: fileName, fileURL: url, to: folder)
            
        case .failure(let error):
            print("File import error: \(error.localizedDescription)")
        }
    }
}

struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        NavigationLink {
            if let fileURL = document.fileURL.flatMap(URL.init(fileURLWithPath:)) {
                PDFViewerScreen(fileURL: fileURL)
            } else {
                Text("File not found")
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(document.name ?? "Unnamed File")
                    if let date = document.createdAt {
                        Text(date.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct NewFolderSheet: View {
    @Binding var isPresented: Bool
    @Binding var newFolderName: String
    @Binding var newFolderIcon: String
    let icons: [String]
    let folderManager: FolderManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Details") {
                    TextField("Folder Name", text: $newFolderName)
                        .autocapitalization(.words)
                    
                    Picker("Icon", selection: $newFolderIcon) {
                        ForEach(icons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }.tag(icon)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        folderManager.addFolder(
                            name: newFolderName.trimmingCharacters(in: .whitespaces),
                            icon: newFolderIcon
                        )
                        isPresented = false
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
