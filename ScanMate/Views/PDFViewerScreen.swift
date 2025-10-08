//
//  PDFViewerScreen.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/24/25.
//


import SwiftUI

struct PDFViewerScreen: View {
    let fileURL: URL
    
    var body: some View {
        PDFKitView(url: fileURL)
            .navigationBarTitle(Text(fileURL.lastPathComponent), displayMode: .inline)
    }
}
