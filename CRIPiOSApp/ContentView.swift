//
//  ContentView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CelebrityViewModel()
    
    var body: some View {
        TabView {
            CelebrityListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Celebrities")
                }
            
            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct CelebrityListView: View {
    @ObservedObject var viewModel: CelebrityViewModel
    @State private var showingAddCelebrity = false
    @State private var searchText = ""
    
    var filteredCelebrities: [Celebrity] {
        if searchText.isEmpty {
            return viewModel.celebrities
        } else {
            return viewModel.searchCelebrities(query: searchText)
        }
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
                        FeaturedCelebritiesView(viewModel: viewModel)
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
                                        NavigationLink(destination: CelebrityDetailView(celebrity: celebrity)) {
                                            CelebrityRowView(celebrity: celebrity)
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
            .refreshable {
                viewModel.loadCelebrities()
            }
            .sheet(isPresented: $showingAddCelebrity) {
                AddCelebrityView(viewModel: viewModel)
            }
        }
    }
}

struct CelebrityRowView: View {
    let celebrity: Celebrity
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: celebrity.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(celebrity.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if celebrity.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                Text(celebrity.occupation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if celebrity.isDeceased {
                    Text("Died: \(celebrity.deathDate ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text("Age: \(celebrity.age)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                // Interests
                if !celebrity.interests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(celebrity.interests.prefix(3), id: \.self) { interest in
                                Text(interest)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(4)
                            }
                            
                            if celebrity.interests.count > 3 {
                                Text("+\(celebrity.interests.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            if celebrity.isDeceased {
                Image(systemName: "heart.slash.fill")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "heart.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CelebrityDetailView: View {
    let celebrity: Celebrity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    AsyncImage(url: URL(string: celebrity.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(celebrity.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if celebrity.isFeatured {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Text(celebrity.occupation)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if celebrity.isDeceased {
                            Text("Deceased")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        } else {
                            Text("Living")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                
                // Interests Section
                if !celebrity.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests & Hobbies")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 8) {
                            ForEach(celebrity.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Age", value: "\(celebrity.age)")
                    
                    if let birthDate = celebrity.birthDate {
                        DetailRow(title: "Birth Date", value: birthDate)
                    }
                    
                    if celebrity.isDeceased, let deathDate = celebrity.deathDate {
                        DetailRow(title: "Death Date", value: deathDate)
                    }
                    
                    if let causeOfDeath = celebrity.causeOfDeath {
                        DetailRow(title: "Cause of Death", value: causeOfDeath)
                    }
                    
                    if let nationality = celebrity.nationality {
                        DetailRow(title: "Nationality", value: nationality)
                    }
                    
                    if let netWorth = celebrity.netWorth {
                        DetailRow(title: "Net Worth", value: netWorth)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle(celebrity.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: CelebrityViewModel
    @State private var searchText = ""
    
    var filteredCelebrities: [Celebrity] {
        viewModel.searchCelebrities(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            List(filteredCelebrities) { celebrity in
                NavigationLink(destination: CelebrityDetailView(celebrity: celebrity)) {
                    CelebrityRowView(celebrity: celebrity)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search celebrities...")
        }
    }
}

struct AddCelebrityView: View {
    @ObservedObject var viewModel: CelebrityViewModel
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

struct SettingsView: View {
    @ObservedObject var viewModel: CelebrityViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showingInterestsSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Personalization") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Interests & Hobbies")
                                .font(.body)
                            
                            if viewModel.userInterests.selectedInterests.isEmpty {
                                Text("No interests selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(viewModel.userInterests.selectedInterests.count) interests selected")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Manage") {
                            showingInterestsSettings = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Death Alerts", isOn: $notificationsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // Open privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // Open terms of service
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingInterestsSettings) {
                InterestsSettingsView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
