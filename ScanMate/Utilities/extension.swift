//
//  extension.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import UIKit
import SwiftUICore
import CoreData

extension UIImage {
    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self
        
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.draw(in: areaSize)
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return mergedImage
    }
}

extension Color {
    var cgColor: CGColor? {
        return UIColor(self).cgColor
    }
}

// Add this extension for notifications
extension Notification.Name {
    static let documentSaved = Notification.Name("DocumentSavedNotification")
}

extension URL {
    var creationDate: Date {
        (try? FileManager.default.attributesOfItem(atPath: self.path)[.creationDate] as? Date) ?? Date()
    }
}

//extension Document {
//    @objc(addTagsObject:)
//    @NSManaged public func addToTags(_ value: Tag)
//
//    @objc(removeTagsObject:)
//    @NSManaged public func removeFromTags(_ value: Tag)
//
//    @objc(addTags:)
//    @NSManaged public func addToTags(_ values: NSSet)
//
//    @objc(removeTags:)
//    @NSManaged public func removeFromTags(_ values: NSSet)
//    
//}

extension Folder {
    // Helper methods for documents
    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)
    
    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)
    
    var documentsArray: [Document] {
        let set = documents as? Set<Document> ?? []
        return Array(set)
    }
    
        func documentCount() -> Int {
            (self.documents as? Set<Document>)?.count ?? 0
        }
    

}

extension Tag {

    
    // Helper methods for documents
    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)
    
    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)
    
    var documentsArray: [Document] {
        let set = documents as? Set<Document> ?? []
        return Array(set)
    }
}

extension PersistenceController {
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }
}
