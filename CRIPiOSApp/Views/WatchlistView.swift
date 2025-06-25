//
//  WatchlistView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct WatchlistView: View {
    @Binding var socialViewModel: SocialViewModel
    @State private var showingAddWatchlistItem = false
    @State private var selectedFilter: WatchlistFilter = .all
    
    enum WatchlistFilter: String, CaseIterable {
        case all = "All"
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var priority: WatchlistPriority? {
            switch self {
            case .all: return nil
            case .critical: return .critical
            case .high: return .high
            case .medium: return .medium
            case .low: return .low
            }
        }
    }
    
    var filteredWatchlistItems: [WatchlistItem] {
        let currentUserItems = socialViewModel.watchlistItems.filter { $0.userId == socialViewModel.currentUser?.id }
        
        if let priority = selectedFilter.priority {
            return currentUserItems.filter { $0.priority == priority }
        } else {
            return currentUserItems
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(WatchlistFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if socialViewModel.isLoggedIn {
                    if filteredWatchlistItems.isEmpty {
                        EmptyWatchlistView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredWatchlistItems, id: \.id) { item in
                                    WatchlistItemCard(
                                        item: item,
                                        socialViewModel: $socialViewModel
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    LoginPromptView(socialViewModel: $socialViewModel)
                }
            }
            .navigationTitle("My Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if socialViewModel.isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddWatchlistItem = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddWatchlistItem) {
                AddWatchlistItemView(socialViewModel: $socialViewModel)
            }
            .refreshable {
                socialViewModel.refreshSocialData()
            }
        }
    }
}

struct WatchlistItemCard: View {
    let item: WatchlistItem
    @Binding var socialViewModel: SocialViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.celebrityName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Added \(item.addedDate, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Priority Badge
                HStack(spacing: 4) {
                    Image(systemName: item.priority.icon)
                        .font(.caption)
                        .foregroundColor(Color(item.priority.color))
                    
                    Text(item.priority.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(item.priority.color))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(item.priority.color).opacity(0.1))
                .cornerRadius(8)
            }
            
            // Notes
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
            }
            
            // Actions
            HStack {
                Button(action: { showingEditSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.caption)
                        Text("Edit")
                            .font(.caption)
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    socialViewModel.removeFromWatchlist(celebrityName: item.celebrityName)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text("Remove")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditSheet) {
            EditWatchlistItemView(item: item, socialViewModel: $socialViewModel)
        }
    }
}

struct EmptyWatchlistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Your Watchlist is Empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add celebrities to your Watchlist to track them and get notified about important updates.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LoginPromptView: View {
    @Binding var socialViewModel: SocialViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Sign In to Use Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Create an account or sign in to start building your celebrity Watchlist.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            #if DEBUG
            // Quick Test Login Buttons
            VStack(spacing: 12) {
                Text("🧪 Quick Test Login (DEBUG)")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                ForEach(UserProfile.sampleProfiles.prefix(3), id: \.id) { profile in
                    Button(action: {
                        socialViewModel.loginUser(username: profile.username)
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(profile.displayName.prefix(1)))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accentColor)
                                )
                            
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
                            
                            Text("Login")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 40)
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddWatchlistItemView: View {
    @Binding var socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCelebrity = ""
    @State private var notes = ""
    @State private var priority: WatchlistPriority = .medium
    @State private var isPublic = true
    @State private var showingCelebrityPicker = false
    
    private let celebrities = [
        "Robin Williams", "David Bowie", "Prince", "Tom Hanks", "Meryl Streep",
        "Morgan Freeman", "Betty White", "Chadwick Boseman", "Michael Jackson",
        "Anna Nicole Smith", "Whitney Houston", "Prince Philip", "Queen Elizabeth II",
        "Paul McCartney", "Mick Jagger", "Keith Richards", "Robert De Niro",
        "Al Pacino", "Denzel Washington", "Julia Roberts"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Celebrity") {
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
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(WatchlistPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section("Privacy") {
                    Toggle("Public Watchlist", isOn: $isPublic)
                    Text("Public Watchlists can be seen by other users")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToWatchlist()
                    }
                    .disabled(selectedCelebrity.isEmpty)
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
    
    private func addToWatchlist() {
        socialViewModel.addToWatchlist(
            celebrityName: selectedCelebrity,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            isPublic: isPublic
        )
        dismiss()
    }
}

struct EditWatchlistItemView: View {
    let item: WatchlistItem
    @Binding var socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var notes: String
    @State private var priority: WatchlistPriority
    @State private var isPublic: Bool
    
    init(item: WatchlistItem, socialViewModel: Binding<SocialViewModel>) {
        self.item = item
        self._socialViewModel = socialViewModel
        self._notes = State(initialValue: item.notes ?? "")
        self._priority = State(initialValue: item.priority)
        self._isPublic = State(initialValue: item.isPublic)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Celebrity") {
                    Text(item.celebrityName)
                        .foregroundColor(.primary)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(WatchlistPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section("Privacy") {
                    Toggle("Public Watchlist", isOn: $isPublic)
                    Text("Public Watchlists can be seen by other users")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Watchlist Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        socialViewModel.updateWatchlistItem(
            item,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            isPublic: isPublic
        )
        dismiss()
    }
} 
