//
//  LoginView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct LoginView: View {
    @Binding var socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSignUp = false
    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var selectedInterests: Set<String> = []
    @State private var showingInterestPicker = false
    
    private let availableInterests = [
        "Acting", "Music", "Comedy", "Film", "Television", "Theater",
        "Classic Hollywood", "Modern Entertainment", "Celebrity News",
        "Health & Wellness", "Mental Health", "Lifestyle", "Fashion",
        "Sports", "Politics", "Technology", "Science", "Art", "Literature"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)
                        
                        Text(isSignUp ? "Join the Community" : "Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(isSignUp ? "Create your profile and start sharing tributes" : "Sign in to your account")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Username
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Display Name (Sign Up only)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter display name", text: $displayName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Bio (Sign Up only)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextEditor(text: $bio)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                            
                            // Interests (Sign Up only)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Interests")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Button(action: { showingInterestPicker = true }) {
                                    HStack {
                                        Text(selectedInterests.isEmpty ? "Select your interests" : "\(selectedInterests.count) interests selected")
                                            .foregroundColor(selectedInterests.isEmpty ? .secondary : .primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Show selected interests
                                if !selectedInterests.isEmpty {
                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 100))
                                    ], spacing: 8) {
                                        ForEach(Array(selectedInterests), id: \.self) { interest in
                                            HStack(spacing: 4) {
                                                Text(interest)
                                                    .font(.caption)
                                                    .foregroundColor(.accentColor)
                                                
                                                Button(action: { selectedInterests.remove(interest) }) {
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
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Button
                    Button(action: handleAction) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canProceed ? Color.accentColor : Color(.systemGray4))
                            .cornerRadius(12)
                    }
                    .disabled(!canProceed)
                    .padding(.horizontal)
                    
                    #if DEBUG
                    // Test Credentials Section
                    VStack(spacing: 16) {
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("🧪 Test Credentials (DEBUG)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Use these for quick testing:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach(UserProfile.sampleProfiles, id: \.id) { profile in
                                Button(action: {
                                    username = profile.username
                                    handleAction()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(profile.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text("@\(profile.username)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    #endif
                    
                    // Toggle Sign Up/Login
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingInterestPicker) {
                InterestPickerView(
                    selectedInterests: $selectedInterests,
                    availableInterests: availableInterests
                )
            }
            .onChange(of: socialViewModel.isLoggedIn) { _, newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
    
    private var canProceed: Bool {
        if isSignUp {
            return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private func handleAction() {
        if isSignUp {
            socialViewModel.createUserProfile(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                bio: bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : bio.trimmingCharacters(in: .whitespacesAndNewlines),
                interests: Array(selectedInterests)
            )
        } else {
            socialViewModel.loginUser(username: username.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}

struct InterestPickerView: View {
    @Binding var selectedInterests: Set<String>
    let availableInterests: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableInterests, id: \.self) { interest in
                    Button(action: {
                        if selectedInterests.contains(interest) {
                            selectedInterests.remove(interest)
                        } else {
                            selectedInterests.insert(interest)
                        }
                    }) {
                        HStack {
                            Text(interest)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedInterests.contains(interest) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Interests")
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
