//
//  ProfileView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/19/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Profile Header
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vrushti Shah")
                                .font(.headline)

                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.gray)
                                Text("Basic")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.trailing)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Upgrade Section
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Upgrade to Premium")
                                .font(.subheadline)
                                .bold()
                            Text("Unlock 20+ Premium privileges")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button("Upgrade") {
                            print("Upgrade tapped")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Privileges Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Privileges")
                            .font(.headline)

                        HStack(spacing: 24) {
                            PrivilegeItem(icon: "icloud", label: "Cloud", value: "0% used")
                            PrivilegeItem(icon: "textformat", label: "Extract Text", value: "6 left")
                            PrivilegeItem(icon: "nosign", label: "No ads", value: "Locked")
                            PrivilegeItem(icon: "book.fill", label: "Book", value: "10 left")
                        }
                    }
                    .padding(.horizontal)

                    // Settings Options
                    VStack(spacing: 1) {
                        ProfileOption(icon: "person", title: "Account")
                        ProfileOption(icon: "arrow.triangle.2.circlepath", title: "Sync")
                        ProfileOption(icon: "camera.viewfinder", title: "Scan")
                        ProfileOption(icon: "doc.text.fill", title: "Document Settings")
                        ProfileOption(icon: "square.grid.2x2", title: "Add Widgets", trailingText: "Quick Scan from Lock Screen")
                        ProfileOption(icon: "gearshape", title: "More Settings")
                        ProfileOption(icon: "questionmark.circle", title: "Help")
                        ProfileOption(icon: "cart", title: "Restore Purchased Items")
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Me")
        }
    }
}

struct PrivilegeItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.teal)

            Text(label)
                .font(.caption2)
                .bold()
                .foregroundColor(.primary)

            Text(value)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileOption: View {
    let icon: String
    let title: String
    var trailingText: String? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if let trailing = trailingText {
                Text(trailing)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
    }
}
