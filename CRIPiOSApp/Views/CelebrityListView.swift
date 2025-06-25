//
//  CelebrityListView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct CelebrityListView: View {
    @Binding var viewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    @Binding var settingsViewModel: SettingsViewModel
    @State private var searchText = ""
    @State private var showingAddCelebrity = false
    @State private var showingNotifications = false
    @State private var showingSettings = false
    @State private var selectedFilter: CelebrityFilter = .all
    
    init(viewModel: Binding<CelebrityViewModel>, 
         socialViewModel: Binding<SocialViewModel>,
         settingsViewModel: Binding<SettingsViewModel>) {
        self._viewModel = viewModel
        self._socialViewModel = socialViewModel
        self._settingsViewModel = settingsViewModel
    }
    
    var filteredCelebrities: [Celebrity] {
        let celebrities = viewModel.fetchCelebrities()
        
        var filtered = celebrities
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { celebrity in
                celebrity.name.localizedCaseInsensitiveContains(searchText) ||
                celebrity.occupation.localizedCaseInsensitiveContains(searchText) ||
                celebrity.interests.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .living:
            filtered = filtered.filter { !$0.isDeceased }
        case .deceased:
            filtered = filtered.filter { $0.isDeceased }
        case .featured:
            filtered = filtered.filter { $0.isFeatured }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search celebrities...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding([.horizontal, .top])
                    
                    LazyVStack(spacing: 20) {
                        // Featured Celebrities Section
                        FeaturedCelebritiesView(viewModel: viewModel,
                                                socialViewModel: socialViewModel)
                            .padding(.horizontal)
                        
                        // All Celebrities Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("All Celebrities")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddCelebrity = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.isLoading {
                                ProgressView("Loading celebrities...")
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(filteredCelebrities) { celebrity in
                                        NavigationLink(destination: CelebrityDetailView(celebrity: celebrity, viewModel: viewModel, socialViewModel: socialViewModel)) {
                                            CelebrityRowView(celebrity: celebrity, viewModel: viewModel)
                                                .padding(.horizontal)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Celebrities")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingNotifications = true
                    }) {
                        ZStack {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            if socialViewModel.getUnreadNotificationCount() > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
            .refreshable {
                viewModel.loadCelebrities()
            }
            .sheet(isPresented: $showingAddCelebrity) {
                AddCelebrityView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationView(socialViewModel: socialViewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(
                    settingsViewModel: $settingsViewModel,
                    celebrityViewModel: $viewModel,
                    socialViewModel: $socialViewModel
                )
            }
        }
    }
}

//struct SearchView: View {
//    @State private var viewModel: CelebrityViewModel
//    @State private var socialViewModel: SocialViewModel
//    @State private var searchText = ""
//    
//    var filteredCelebrities: [Celebrity] {
//        viewModel.searchCelebrities(query: searchText)
//    }
//    
//    var body: some View {
//        NavigationView {
//            List(filteredCelebrities) { celebrity in
//                NavigationLink(destination: CelebrityDetailView(
//                    celebrity: celebrity, 
//                    viewModel: viewModel,
//                    socialViewModel: socialViewModel
//                )) {
//                    CelebrityRowView(celebrity: celebrity, viewModel: $viewModel)
//                }
//            }
//            .navigationTitle("Search")
//            .navigationBarTitleDisplayMode(.large)
//            .searchable(text: $searchText, prompt: "Search celebrities...")
//        }
//    }
//}

struct AddCelebrityView: View {
    @State private var viewModel: CelebrityViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var occupation = ""
    @State private var age = ""
    @State private var isDeceased = false
    @State private var deathDate = ""
    @State private var birthDate = ""
    @State private var causeOfDeath = ""
    @State private var nationality = ""
    @State private var netWorth = ""
    @State private var interests = ""
    @State private var isFeatured = false
    
    init(viewModel: CelebrityViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    TextField("Occupation", text: $occupation)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Nationality", text: $nationality)
                }
                
                Section("Status") {
                    Toggle("Deceased", isOn: $isDeceased)
                    Toggle("Featured", isOn: $isFeatured)
                    
                    if isDeceased {
                        TextField("Death Date", text: $deathDate)
                        TextField("Cause of Death", text: $causeOfDeath)
                    }
                }
                
                Section("Additional Information") {
                    TextField("Birth Date", text: $birthDate)
                    TextField("Net Worth", text: $netWorth)
                    TextField("Interests (comma separated)", text: $interests)
                }
            }
            .navigationTitle("Add Celebrity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCelebrity()
                    }
                    .disabled(name.isEmpty || occupation.isEmpty || age.isEmpty)
                }
            }
        }
    }
    
    private func saveCelebrity() {
        guard let ageInt = Int(age) else { return }
        
        let interestArray = interests.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let celebrity = Celebrity(
            name: name,
            occupation: occupation,
            age: ageInt,
            imageURL: "",
            isDeceased: isDeceased,
            deathDate: isDeceased ? deathDate : nil,
            birthDate: birthDate.isEmpty ? nil : birthDate,
            causeOfDeath: isDeceased && !causeOfDeath.isEmpty ? causeOfDeath : nil,
            nationality: nationality.isEmpty ? nil : nationality,
            netWorth: netWorth.isEmpty ? nil : netWorth,
            interests: interestArray,
            isFeatured: isFeatured
        )
        
        viewModel.addCelebrity(celebrity)
        dismiss()
    }
}

// MARK: - Supporting Types

enum CelebrityFilter: String, CaseIterable {
    case all = "All"
    case living = "Living"
    case deceased = "Deceased"
    case featured = "Featured"
    
    var icon: String {
        switch self {
        case .all: return "person.3.fill"
        case .living: return "heart.fill"
        case .deceased: return "heart.slash.fill"
        case .featured: return "star.fill"
        }
    }
}
