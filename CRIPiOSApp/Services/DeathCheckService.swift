//
//  DeathCheckService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation

class DeathCheckService {
    private let networkService = NetworkService.shared
    private var celebrityViewModel: CelebrityViewModel?
    
    init(celebrityViewModel: CelebrityViewModel? = nil) {
        self.celebrityViewModel = celebrityViewModel
    }
    
    func setCelebrityViewModel(_ celebrityViewModel: CelebrityViewModel) {
        self.celebrityViewModel = celebrityViewModel
    }
    
    // MARK: - Public Methods
    
    func checkForNewDeaths() async -> [Celebrity] {
        let currentCelebrities = celebrityViewModel?.fetchCelebrities() ?? []
        
        var newDeaths: [Celebrity] = []
        
        for celebrity in currentCelebrities {
            // Skip if already known to be deceased
            if celebrity.isDeceased {
                continue
            }
            
            // Check for death date from Wikipedia/Wikidata
            if let deathDate = await networkService.fetchDeathDateFromWikipedia(for: celebrity.name) {
                // Update the existing celebrity object directly
                celebrity.isDeceased = true
                celebrity.deathDate = deathDate
                celebrity.lastUpdated = Date()
                
                newDeaths.append(celebrity)
                
                // Update the celebrity in the view model
                await MainActor.run {
                    celebrityViewModel?.updateCelebrity(celebrity)
                }
            }
        }
        
        return newDeaths
    }
    
    func checkSpecificCelebrity(_ celebrity: Celebrity) async -> Celebrity? {
        guard !celebrity.isDeceased else { return nil }
        
        if let deathDate = await networkService.fetchDeathDateFromWikipedia(for: celebrity.name) {
            // Update the existing celebrity object directly
            celebrity.isDeceased = true
            celebrity.deathDate = deathDate
            celebrity.lastUpdated = Date()
            
            // Update the celebrity in the view model
            await MainActor.run {
                celebrityViewModel?.updateCelebrity(celebrity)
            }
            
            return celebrity
        }
        
        return nil
    }
    
    func refreshAllCelebrities() async -> [Celebrity] {
        let currentCelebrities = celebrityViewModel?.fetchCelebrities() ?? []
        var updatedCelebrities: [Celebrity] = []
        
        for celebrity in currentCelebrities {
            if let deathDate = await networkService.fetchDeathDateFromWikipedia(for: celebrity.name) {
                // Update the existing celebrity object directly
                celebrity.isDeceased = true
                celebrity.deathDate = deathDate
                celebrity.lastUpdated = Date()
                updatedCelebrities.append(celebrity)
            }
        }
        
        // Update all celebrities in the view model
        await MainActor.run {
            for updatedCelebrity in updatedCelebrities {
                celebrityViewModel?.updateCelebrity(updatedCelebrity)
            }
        }
        
        return updatedCelebrities
    }
    
    // MARK: - Test Methods
    
    /// Test method to simulate death detection for Sophia Leone
    /// This demonstrates how the death alerts would work in practice
    func testSophiaLeoneDeathDetection() async -> [Celebrity] {
        // Simulate finding Sophia Leone in our database
        let currentCelebrities = celebrityViewModel?.fetchCelebrities() ?? []
        let sophiaLeone = currentCelebrities.first { $0.name == "Sophia Leone" }
        
        guard let sophia = sophiaLeone else {
            return []
        }
        
        // Simulate the death check process
        // In a real scenario, this would call the Wikipedia/Wikidata API
        // For testing, we'll simulate finding her death information
        let simulatedDeathDate = "March 1, 2024"
        let simulatedCauseOfDeath = "Under investigation (robbery and homicide)"
        
        // Update the existing celebrity object directly
        sophia.isDeceased = true
        sophia.deathDate = simulatedDeathDate
        sophia.causeOfDeath = simulatedCauseOfDeath
        sophia.lastUpdated = Date()
        
        // Update the celebrity in the view model
        await MainActor.run {
            celebrityViewModel?.updateCelebrity(sophia)
            
            // Trigger in-app alert if app is active
            if CronService.shared.isAppActive {
                CronService.shared.deathAlertCelebrities = [sophia]
                CronService.shared.showingDeathAlert = true
            }
        }
        
        return [sophia]
    }
    
    /// Test method to simulate the full death check process
    func testFullDeathCheckProcess() async {
        // Step 1: Load current celebrities
        let currentCelebrities = celebrityViewModel?.fetchCelebrities() ?? []
        let livingCelebrities = currentCelebrities.filter { !$0.isDeceased }
        
        // Step 2: Simulate checking each living celebrity
        var newDeaths: [Celebrity] = []
        
        for celebrity in livingCelebrities.prefix(5) { // Check first 5 for demo
            // Simulate API call delay
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // For this test, only Sophia Leone will be "found" deceased
            if celebrity.name == "Sophia Leone" {
                celebrity.isDeceased = true
                celebrity.deathDate = "March 1, 2024"
                celebrity.causeOfDeath = "Under investigation"
                celebrity.lastUpdated = Date()
                
                newDeaths.append(celebrity)
            }
        }
        
        // Step 3: Update database and send notifications
        if !newDeaths.isEmpty {
            await MainActor.run {
                for updatedCelebrity in newDeaths {
                    celebrityViewModel?.updateCelebrity(updatedCelebrity)
                }
                
                // Trigger in-app alert if app is active
                if CronService.shared.isAppActive {
                    CronService.shared.deathAlertCelebrities = newDeaths
                    CronService.shared.showingDeathAlert = true
                }
            }
        }
    }
} 
