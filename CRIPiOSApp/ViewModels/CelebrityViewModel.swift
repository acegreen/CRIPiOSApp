//
//  CelebrityViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class CelebrityViewModel {
    private var modelContext: ModelContext?
    var isLoading = false
    var errorMessage: String?
    var userInterests: UserInterests = UserInterests()
    private var imageCache: [String: String] = [:] // name -> imageURL
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadUserInterests()
        setupInitialData()
    }
    
    // MARK: - SwiftData Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        setupInitialData()
    }
    
    func clearAndReloadData() {
        guard let modelContext = modelContext else { return }
        
        print("🗑️ Clearing all celebrities from database...")
        
        // Fetch and delete all existing celebrities
        let descriptor = FetchDescriptor<Celebrity>()
        do {
            let existingCelebrities = try modelContext.fetch(descriptor)
            for celebrity in existingCelebrities {
                modelContext.delete(celebrity)
            }
            try modelContext.save()
            print("✅ Cleared \(existingCelebrities.count) celebrities from database")
        } catch {
            print("❌ Error clearing celebrities: \(error)")
        }
        
        // Reload sample data
        loadSampleData()
    }
    
    private func setupInitialData() {
        guard let modelContext = modelContext else { return }
        
        // Check if we have any celebrities in the database
        let descriptor = FetchDescriptor<Celebrity>()
        do {
            let existingCelebrities = try modelContext.fetch(descriptor)
            if existingCelebrities.isEmpty {
                // Load sample data if database is empty
                loadSampleData()
            } else {
                print("📊 Found \(existingCelebrities.count) existing celebrities in database")
            }
        } catch {
            print("❌ Error fetching celebrities: \(error)")
            // If there's an error, it might be due to schema changes
            // Clear and reload data to fix migration issues
            print("🔄 Clearing database due to schema migration issues...")
            clearAndReloadData()
        }
    }
    
    private func loadSampleData() {
        guard let modelContext = modelContext else { return }
        
        print("📊 Loading sample celebrity data...")
        for celebrity in Celebrity.sampleCelebrities {
            modelContext.insert(celebrity)
        }
        
        do {
            try modelContext.save()
            print("✅ Sample data loaded successfully")
        } catch {
            print("❌ Error saving sample data: \(error)")
        }
    }
    
    // MARK: - CRON Service Support
    
    func refreshCelebrities() {
        // Trigger a refresh of the celebrities list
        print("🔄 Refreshing celebrities list...")
        // With @Observable, changes are automatically detected
    }
    
    func loadCelebrities() {
        // This is now handled by SwiftData automatically
        print("📊 Celebrities loaded from SwiftData")
    }
    
    func addCelebrity(_ celebrity: Celebrity) {
        guard let modelContext = modelContext else { return }
        modelContext.insert(celebrity)
        saveContext()
    }
    
    func updateCelebrity(_ celebrity: Celebrity) {
        celebrity.lastUpdated = Date()
        saveContext()
        print("✅ Updated celebrity: \(celebrity.name) (isDeceased: \(celebrity.isDeceased))")
    }
    
    func deleteCelebrity(_ celebrity: Celebrity) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(celebrity)
        saveContext()
    }
    
    private func saveContext() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    // MARK: - Fetch Methods
    
    func fetchCelebrities() -> [Celebrity] {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Celebrity>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching celebrities: \(error)")
            return []
        }
    }
    
    func getRecentDeaths() -> [Celebrity] {
        let celebrities = fetchCelebrities()
        let sortedDeaths = celebrities
            .filter { $0.isDeceased && $0.deathDateValue != nil }
            .sorted { $0.deathDateValue! > $1.deathDateValue! }
        return sortedDeaths
    }
    
    func getFeaturedCelebrities() -> [Celebrity] {
        let celebrities = fetchCelebrities()
        let featuredCelebrities = celebrities.filter { $0.isFeatured }
        
        // Return featured celebrities with living ones first (no personalization)
        return featuredCelebrities.sorted { celebrity1, celebrity2 in
            if celebrity1.isDeceased != celebrity2.isDeceased {
                return !celebrity1.isDeceased
            }
            return celebrity1.name < celebrity2.name
        }
    }
    
    func getPersonalizedFeaturedCelebrities() -> [Celebrity] {
        let celebrities = fetchCelebrities()
        let allInterests = userInterests.selectedInterests.union(Set(userInterests.customInterests))
        
        if allInterests.isEmpty {
            return getFeaturedCelebrities()
        }
        
        return celebrities.filter { celebrity in
            !celebrity.interests.filter { allInterests.contains($0) }.isEmpty
        }.sorted { celebrity1, celebrity2 in
            let matches1 = celebrity1.interests.filter { allInterests.contains($0) }.count
            let matches2 = celebrity2.interests.filter { allInterests.contains($0) }.count
            
            if matches1 != matches2 {
                return matches1 > matches2
            }
            
            // If same number of matches, prioritize featured celebrities
            if celebrity1.isFeatured != celebrity2.isFeatured {
                return celebrity1.isFeatured
            }
            
            // Then prioritize living celebrities
            if celebrity1.isDeceased != celebrity2.isDeceased {
                return !celebrity1.isDeceased
            }
            
            return celebrity1.name < celebrity2.name
        }
    }
    
    func searchCelebrities(query: String) -> [Celebrity] {
        let celebrities = fetchCelebrities()
        if query.isEmpty {
            return celebrities
        }
        
        return celebrities.filter { celebrity in
            celebrity.name.localizedCaseInsensitiveContains(query) ||
            celebrity.occupation.localizedCaseInsensitiveContains(query) ||
            (celebrity.nationality?.localizedCaseInsensitiveContains(query) ?? false) ||
            celebrity.interests.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func getCelebritiesByOccupation(_ occupation: String) -> [Celebrity] {
        let celebrities = fetchCelebrities()
        return celebrities.filter { $0.occupation.localizedCaseInsensitiveContains(occupation) }
    }
    
    func getCelebritiesByInterest(_ interest: String) -> [Celebrity] {
        let celebrities = fetchCelebrities()
        return celebrities.filter { $0.interests.contains(interest) }
    }
    
    // MARK: - User Interests Management
    func loadUserInterests() {
        if let data = UserDefaults.standard.data(forKey: "userInterests"),
           let interests = try? JSONDecoder().decode(UserInterests.self, from: data) {
            userInterests = interests
        }
    }
    
    func saveUserInterests() {
        if let data = try? JSONEncoder().encode(userInterests) {
            UserDefaults.standard.set(data, forKey: "userInterests")
        }
    }
    
    func clearUserInterests() {
        userInterests = UserInterests()
        UserDefaults.standard.removeObject(forKey: "userInterests")
    }
    
    func addUserInterest(_ interest: String) {
        userInterests.selectedInterests.insert(interest)
        saveUserInterests()
    }
    
    func removeUserInterest(_ interest: String) {
        userInterests.selectedInterests.remove(interest)
        userInterests.customInterests.removeAll { $0 == interest }
        saveUserInterests()
    }
    
    func addCustomInterest(_ interest: String) {
        if !userInterests.customInterests.contains(interest) {
            userInterests.customInterests.append(interest)
            userInterests.selectedInterests.insert(interest)
            saveUserInterests()
        }
    }
    
    // MARK: - Image Fetching
    func imageURL(for celebrity: Celebrity) async -> String? {
        if let cached = imageCache[celebrity.name] {
            return cached
        }
        if !celebrity.imageURL.isEmpty {
            imageCache[celebrity.name] = celebrity.imageURL
            return celebrity.imageURL
        }
        // Fetch from Wikipedia using NetworkService
        if let url = await NetworkService.shared.fetchWikipediaImageURL(for: celebrity.name) {
            imageCache[celebrity.name] = url
            return url
        }
        return nil
    }
    
    // MARK: - Death Date Fetching
    func fetchAndUpdateDeathDates() async {
        let celebrities = fetchCelebrities()
        for celebrity in celebrities where !celebrity.isDeceased {
            if let deathDate = await NetworkService.shared.fetchDeathDateFromWikipedia(for: celebrity.name) {
                // Update the existing celebrity object directly
                celebrity.isDeceased = true
                celebrity.deathDate = deathDate
                celebrity.lastUpdated = Date()
                updateCelebrity(celebrity)
            }
        }
    }
    
    // MARK: - Batch Update Methods for CRON Service
    
    func updateCelebritiesFromDeathCheck(_ updatedCelebrities: [Celebrity]) {
        guard let modelContext = modelContext else { return }
        
        let existingCelebrities = fetchCelebrities()
        
        for updatedCelebrity in updatedCelebrities {
            if let existingCelebrity = existingCelebrities.first(where: { $0.name == updatedCelebrity.name }) {
                // Update existing celebrity
                existingCelebrity.isDeceased = updatedCelebrity.isDeceased
                existingCelebrity.deathDate = updatedCelebrity.deathDate
                existingCelebrity.causeOfDeath = updatedCelebrity.causeOfDeath
                existingCelebrity.lastUpdated = Date()
            } else {
                // Create new celebrity
                modelContext.insert(updatedCelebrity)
            }
        }
        
        saveContext()
        print("✅ Updated \(updatedCelebrities.count) celebrities from death check")
    }
    
    // MARK: - Helper Methods
    
    func getSophiaLeoneFromDB() -> Celebrity? {
        return fetchCelebrities().first { $0.name == "Sophia Leone" }
    }
} 
