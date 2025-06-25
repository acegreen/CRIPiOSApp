//
//  CreateTributeView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct CreateTributeView: View {
    let socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCelebrity = ""
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var showingCelebrityPicker = false
    
    private let celebrities = [
        "Robin Williams", "David Bowie", "Prince", "Tom Hanks", "Meryl Streep",
        "Morgan Freeman", "Betty White", "Chadwick Boseman", "Michael Jackson",
        "Anna Nicole Smith", "Whitney Houston", "Prince Philip", "Queen Elizabeth II"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Celebrity Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Celebrity")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: { showingCelebrityPicker = true }) {
                            HStack {
                                if selectedCelebrity.isEmpty {
                                    Text("Select a celebrity")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(selectedCelebrity)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter tribute title...", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Tribute")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Add new tag
                        HStack {
                            TextField("Add a tag...", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title2)
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        // Display existing tags
                        if !tags.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80))
                            ], spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag)
                                            .font(.caption)
                                            .foregroundColor(.accentColor)
                                        
                                        Button(action: { removeTag(tag) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(content.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Tribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createTribute()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canPost)
                }
            }
            .sheet(isPresented: $showingCelebrityPicker) {
                CelebrityPickerView(
                    selectedCelebrity: $selectedCelebrity,
                    celebrities: celebrities
                )
            }
        }
    }
    
    private var canPost: Bool {
        !selectedCelebrity.isEmpty && 
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func createTribute() {
        guard canPost else { return }
        
        socialViewModel.createTribute(
            celebrityName: selectedCelebrity,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags
        )
        
        dismiss()
    }
}

struct CelebrityPickerView: View {
    @Binding var selectedCelebrity: String
    let celebrities: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(celebrities, id: \.self) { celebrity in
                Button(action: {
                    selectedCelebrity = celebrity
                    dismiss()
                }) {
                    HStack {
                        Text(celebrity)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedCelebrity == celebrity {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Celebrity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 