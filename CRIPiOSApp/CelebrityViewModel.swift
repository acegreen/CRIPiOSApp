//
//  CelebrityViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftUI

@MainActor
class CelebrityViewModel: ObservableObject {
    @Published var celebrities: [Celebrity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userInterests: UserInterests = UserInterests()
    
    init() {
        loadCelebrities()
        loadUserInterests()
    }
    
    func loadCelebrities() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.celebrities = Celebrity.sampleCelebrities
            self.isLoading = false
        }
    }
    
    func addCelebrity(_ celebrity: Celebrity) {
        celebrities.append(celebrity)
        saveCelebrities()
    }
    
    func updateCelebrity(_ celebrity: Celebrity) {
        if let index = celebrities.firstIndex(where: { $0.id == celebrity.id }) {
            celebrities[index] = celebrity
            saveCelebrities()
        }
    }
    
    func deleteCelebrity(_ celebrity: Celebrity) {
        celebrities.removeAll { $0.id == celebrity.id }
        saveCelebrities()
    }
    
    func getRecentDeaths() -> [Celebrity] {
        return celebrities.filter { $0.isDeceased }
            .sorted { (celebrity1, celebrity2) in
                guard let date1 = celebrity1.deathDate, let date2 = celebrity2.deathDate else {
                    return false
                }
                return date1 > date2
            }
    }
    
    func getFeaturedCelebrities() -> [Celebrity] {
        let featuredCelebrities = celebrities.filter { $0.isFeatured }
        
        // If user has interests, prioritize celebrities with matching interests
        if !userInterests.selectedInterests.isEmpty {
            return featuredCelebrities.sorted { celebrity1, celebrity2 in
                let matches1 = celebrity1.interests.filter { userInterests.selectedInterests.contains($0) }.count
                let matches2 = celebrity2.interests.filter { userInterests.selectedInterests.contains($0) }.count
                
                if matches1 != matches2 {
                    return matches1 > matches2
                }
                
                // If same number of matches, prioritize living celebrities
                if celebrity1.isDeceased != celebrity2.isDeceased {
                    return !celebrity1.isDeceased
                }
                
                return celebrity1.name < celebrity2.name
            }
        }
        
        // If no user interests, return featured celebrities with living ones first
        return featuredCelebrities.sorted { celebrity1, celebrity2 in
            if celebrity1.isDeceased != celebrity2.isDeceased {
                return !celebrity1.isDeceased
            }
            return celebrity1.name < celebrity2.name
        }
    }
    
    func getPersonalizedFeaturedCelebrities() -> [Celebrity] {
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
        return celebrities.filter { $0.occupation.localizedCaseInsensitiveContains(occupation) }
    }
    
    func getCelebritiesByInterest(_ interest: String) -> [Celebrity] {
        return celebrities.filter { $0.interests.contains(interest) }
    }
    
    func getStatistics() -> CelebrityStatistics {
        let total = celebrities.count
        let deceased = celebrities.filter { $0.isDeceased }.count
        let living = total - deceased
        
        let averageAge = celebrities.map { $0.age }.reduce(0, +) / max(celebrities.count, 1)
        
        let occupations = Dictionary(grouping: celebrities, by: { $0.occupation })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let interests = Dictionary(grouping: celebrities.flatMap { $0.interests }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return CelebrityStatistics(
            total: total,
            deceased: deceased,
            living: living,
            averageAge: averageAge,
            topOccupations: Array(occupations.prefix(5)),
            topInterests: Array(interests.prefix(5))
        )
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
    
    private func saveCelebrities() {
        // In a real app, this would save to Core Data or a backend
        // For now, we'll just update the published property
        objectWillChange.send()
    }
}

struct CelebrityStatistics {
    let total: Int
    let deceased: Int
    let living: Int
    let averageAge: Int
    let topOccupations: [(String, Int)]
    let topInterests: [(String, Int)]
} 