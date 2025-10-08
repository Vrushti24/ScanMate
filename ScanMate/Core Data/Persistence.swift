//
//  Persistence.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample folders
        let workFolder = Folder(context: viewContext)
        workFolder.id = UUID()
        workFolder.name = "Work"
        workFolder.icon = "briefcase"
        workFolder.createdAt = Date()
        
        let personalFolder = Folder(context: viewContext)
        personalFolder.id = UUID()
        personalFolder.name = "Personal"
        personalFolder.icon = "person"
        personalFolder.createdAt = Date()
        
        // Create sample tags
        let importantTag = Tag(context: viewContext)
        importantTag.id = UUID()
        importantTag.name = "Important"
        importantTag.color = "red"
        
        let receiptTag = Tag(context: viewContext)
        receiptTag.id = UUID()
        receiptTag.name = "Receipt"
        receiptTag.color = "green"
        
        // Create sample document
        let document = Document(context: viewContext)
        document.id = UUID()
        document.name = "Sample Document"
        document.fileURL = "sample_path.pdf"
        document.createdAt = Date()
        document.folder = workFolder
        document.addToTags(importantTag)
        document.addToTags(receiptTag)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ScanMate")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable automatic migration
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Configure context settings
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Helper function to save context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
