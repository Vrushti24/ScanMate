//
//  ScanMateApp.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI

@main
struct ScanMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
