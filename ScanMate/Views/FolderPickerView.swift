//
//  FolderPickerView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//

import SwiftUICore
import SwiftUI


struct FolderPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
        animation: .default
    ) private var folders: FetchedResults<Folder>
    
    @Binding var selectedFolder: Folder?
    var onDismiss: () -> Void
    
    @State private var newFolderName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("New Folder") {
                    HStack {
                        TextField("Folder Name", text: $newFolderName)
                        Button("Add") {
                            addNewFolder()
                        }
                        .disabled(newFolderName.isEmpty)
                    }
                }
                
                Section("Existing Folders") {
                    ForEach(folders) { folder in
                        HStack {
                            Image(systemName: folder.icon ?? "folder")
                            Text(folder.name ?? "Unnamed Folder")
                            
                            Spacer()
                            
                            if selectedFolder?.objectID == folder.objectID {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFolder = folder
                        }
                    }
                    .onDelete(perform: deleteFolders)
                }
            }
            .navigationTitle("Select Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func addNewFolder() {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.name = newFolderName
        newFolder.icon = "folder"
        newFolder.createdAt = Date()
        
        do {
            try viewContext.save()
            newFolderName = ""
        } catch {
            print("Error saving folder: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
    
    private func deleteFolders(at offsets: IndexSet) {
        offsets.map { folders[$0] }.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
            // Clear selection if deleted folder was selected
            if let selectedID = selectedFolder?.objectID,
               offsets.contains(where: { folders[$0].objectID == selectedID }) {
                selectedFolder = nil
            }
        } catch {
            print("Error deleting folders: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}
