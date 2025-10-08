//
//  Enums.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/20/25.
//

import Foundation

enum CropCorner: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum OCRSource {
    case camera
    case photos
    case files
}

enum OCRError: Error {
    case invalidImage
    case noTextFound
}

enum ProcessingMode {
    case normal
    case ocr
}

// MARK: - Error Types
enum FolderManagerError: Error, LocalizedError {
    case validationError(String)
    case fetchError(String)
    case coreDataError(String)
    case fileOperationError(String)
    
    var localizedDescription: String {
        switch self {
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .fetchError(let message):
            return "Fetch Error: \(message)"
        case .coreDataError(let message):
            return "Core Data Error: \(message)"
        case .fileOperationError(let message):
            return "File Operation Error: \(message)"
        }
    }
}
