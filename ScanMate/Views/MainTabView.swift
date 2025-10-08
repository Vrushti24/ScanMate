//
//  MainTabView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showScanView = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                FilesView()
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Files")
                    }
                    .tag(0)

                FoldersView()
                    .tabItem { Label("Folders", systemImage: "folder") }
                    .tag(2)
            }
            .accentColor(.mint)

            HStack {
                Spacer()

                Button(action: {
                    showScanView = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding(22)
                        .background(
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .offset(y: -20)
                .sheet(isPresented: $showScanView) {
                    ScanView()
                }

                Spacer()
            }
        }
    }
}
