//
//  ScanMateApp.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI
import CoreData

@main
struct ScanMateApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var folderManager: FolderManager
    
    init() {
        let manager = FolderManager(context: PersistenceController.shared.container.viewContext)
        _folderManager = StateObject(wrappedValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(folderManager)
                .onAppear {
                    setupInitialDataIfNeeded()
                }
        }
    }
    
    private func setupInitialDataIfNeeded() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                createDefaultFolders(in: context)
                // Refresh the folder manager after creating defaults
                folderManager.fetchFolders()
            }
        } catch {
            print("Error checking for existing folders: \(error.localizedDescription)")
        }
    }
    
    private func createDefaultFolders(in context: NSManagedObjectContext) {
        let defaultFolders = [
            ("Work", "briefcase"),
            ("Personal", "person"),
            ("Receipts", "cart"),
            ("Contracts", "doc.text")
        ]
        
        for (name, icon) in defaultFolders {
            let folder = Folder(context: context)
            folder.id = UUID()
            folder.name = name
            folder.icon = icon
            folder.createdAt = Date()
        }
        
        do {
            try context.save()
            print("Default folders created successfully")
        } catch {
            print("Error creating default folders: \(error.localizedDescription)")
        }
    }
}
