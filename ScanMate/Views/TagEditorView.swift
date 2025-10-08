//
//  TagEditorView.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/25/25.
//

import SwiftUICore
import SwiftUI


struct TagEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTags: Set<Tag>
    @Binding var newTagName: String
    var allTags: [Tag]
    var onDismiss: () -> Void
    
    let tagColors = ["red", "blue", "green", "yellow", "purple", "orange"]
    @State private var newTagColor = "red"
    
    var body: some View {
        NavigationStack {
            List {
                Section("New Tag") {
                    HStack {
                        TextField("Tag Name", text: $newTagName)
                        
                        Picker("", selection: $newTagColor) {
                            ForEach(tagColors, id: \.self) { color in
                                Text(color.capitalized)
                                    .tag(color)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Button("Add") {
                            addNewTag()
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
                
                Section("Available Tags") {
                    ForEach(allTags) { tag in
                        HStack {
                            Circle()
                                .fill(Color(tag.color ?? "red"))
                                .frame(width: 8, height: 8)
                            Text(tag.name ?? "Unknown")
                            
                            Spacer()
                            
                            if selectedTags.contains(where: { $0.objectID == tag.objectID }) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTagSelection(tag)
                        }
                    }
                    .onDelete(perform: deleteTags)
                }
            }
            .navigationTitle("Manage Tags")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        // Filter out any invalid tags before dismissing
                        selectedTags = selectedTags.filter { $0.managedObjectContext != nil }
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func addNewTag() {
        withAnimation {
            let newTag = Tag(context: viewContext)
            newTag.id = UUID()
            newTag.name = newTagName
            newTag.color = newTagColor
            
            do {
                try viewContext.save()
                selectedTags.insert(newTag)
                newTagName = ""
            } catch {
                print("Error saving tag: \(error.localizedDescription)")
                viewContext.rollback()
            }
        }
    }
    
    private func toggleTagSelection(_ tag: Tag) {
        withAnimation {
            if let existing = selectedTags.first(where: { $0.objectID == tag.objectID }) {
                selectedTags.remove(existing)
            } else {
                // Ensure we're working with the correct context
                if let tagInContext = try? viewContext.existingObject(with: tag.objectID) as? Tag {
                    selectedTags.insert(tagInContext)
                }
            }
        }
    }
    
    private func deleteTags(at offsets: IndexSet) {
        withAnimation {
            offsets.map { allTags[$0] }.forEach { tag in
                // Remove from selected tags
                if let existing = selectedTags.first(where: { $0.objectID == tag.objectID }) {
                    selectedTags.remove(existing)
                }
                viewContext.delete(tag)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting tag: \(error.localizedDescription)")
                viewContext.rollback()
            }
        }
    }
}
