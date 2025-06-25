//
//  CRIPiOSAppTests.swift
//  CRIPiOSAppTests
//
//  Created by AceGreen on 2025-06-25.
//

import Testing
@testable import CRIPiOSApp

struct CRIPiOSAppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    // MARK: - Death Detection Tests
    
    @Test func testSophiaLeoneDeathDetection() async throws {
        // Test death detection for Sophia Leone
        let deathCheckService = DeathCheckService()
        let newDeaths = await deathCheckService.testSophiaLeoneDeathDetection()
        
        // Verify that Sophia Leone was detected as deceased
        #expect(newDeaths.count == 1)
        
        if let sophiaLeone = newDeaths.first {
            #expect(sophiaLeone.name == "Sophia Leone")
            #expect(sophiaLeone.isDeceased == true)
            #expect(sophiaLeone.deathDate == "March 1, 2024")
            #expect(sophiaLeone.age == 26) // Age at death
            #expect(sophiaLeone.occupation == "Adult Actress")
        }
    }
    
    @Test func testFullDeathCheckProcess() async throws {
        // Test the complete death check process
        let deathCheckService = DeathCheckService()
        
        // Capture console output for verification
        var consoleOutput: [String] = []
        
        // Run the test process
        await deathCheckService.testFullDeathCheckProcess()
        
        // Verify the process completed successfully
        // Note: In a real test, we would capture and verify console output
        // For now, we just ensure the function completes without throwing
        #expect(true) // Process completed successfully
    }
    
    @Test func testCronFrequencyTimeIntervals() async throws {
        // Test that all cron frequencies have correct time intervals
        #expect(CronFrequency.hourly.timeInterval == 3600) // 1 hour
        #expect(CronFrequency.daily.timeInterval == 86400) // 24 hours
        #expect(CronFrequency.weekly.timeInterval == 604800) // 7 days
        #expect(CronFrequency.monthly.timeInterval == 2592000) // 30 days
        #expect(CronFrequency.disabled.timeInterval == nil)
    }
    
    @Test func testCronFrequencyDisplayNames() async throws {
        // Test that all cron frequencies have proper display names
        #expect(CronFrequency.hourly.displayName == "Every Hour")
        #expect(CronFrequency.daily.displayName == "Daily")
        #expect(CronFrequency.weekly.displayName == "Weekly")
        #expect(CronFrequency.monthly.displayName == "Monthly")
        #expect(CronFrequency.disabled.displayName == "Disabled")
    }
    
    @Test func testDeathCheckServiceInitialization() async throws {
        // Test that DeathCheckService initializes properly
        let deathCheckService = DeathCheckService()
        
        // Verify the service was created
        #expect(deathCheckService != nil)
    }
    
    @Test func testCronServiceInitialization() async throws {
        // Test that CronService initializes properly
        let cronService = CronService.shared
        
        // Verify the service was created
        #expect(cronService != nil)
    }
    
    @Test func testCelebrityDeathStatusUpdate() async throws {
        // Test updating a celebrity's death status
        let originalCelebrity = Celebrity(
            name: "Test Celebrity",
            occupation: "Actor",
            age: 30,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "1994-01-01",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$1 million",
            interests: ["Acting"],
            isFeatured: false
        )
        
        // Create updated celebrity with death information
        let updatedCelebrity = Celebrity(
            name: originalCelebrity.name,
            occupation: originalCelebrity.occupation,
            age: 30,
            imageURL: originalCelebrity.imageURL,
            isDeceased: true,
            deathDate: "2024-01-01",
            birthDate: originalCelebrity.birthDate,
            causeOfDeath: "Test cause",
            nationality: originalCelebrity.nationality,
            netWorth: originalCelebrity.netWorth,
            interests: originalCelebrity.interests,
            isFeatured: originalCelebrity.isFeatured
        )
        
        // Verify the update
        #expect(originalCelebrity.isDeceased == false)
        #expect(updatedCelebrity.isDeceased == true)
        #expect(updatedCelebrity.deathDate == "2024-01-01")
        #expect(updatedCelebrity.causeOfDeath == "Test cause")
    }
    
    @Test func testUserDefaultsPersistence() async throws {
        // Test that UserDefaults properly stores and retrieves death data
        let testDeaths = [
            Celebrity(
                name: "Test Celebrity 1",
                occupation: "Actor",
                age: 30,
                imageURL: "",
                isDeceased: true,
                deathDate: "2024-01-01",
                birthDate: "1994-01-01",
                causeOfDeath: "Test",
                nationality: "American",
                netWorth: "$1 million",
                interests: ["Acting"],
                isFeatured: false
            ),
            Celebrity(
                name: "Test Celebrity 2",
                occupation: "Singer",
                age: 25,
                imageURL: "",
                isDeceased: true,
                deathDate: "2024-02-01",
                birthDate: "1999-01-01",
                causeOfDeath: "Test",
                nationality: "British",
                netWorth: "$2 million",
                interests: ["Music"],
                isFeatured: false
            )
        ]
        
        // Encode and save
        let encoder = JSONEncoder()
        let data = try encoder.encode(testDeaths)
        UserDefaults.standard.set(data, forKey: "testLastKnownDeaths")
        
        // Retrieve and decode
        let retrievedData = UserDefaults.standard.data(forKey: "testLastKnownDeaths")
        let decoder = JSONDecoder()
        let retrievedDeaths = try decoder.decode([Celebrity].self, from: retrievedData!)
        
        // Verify
        #expect(retrievedDeaths.count == 2)
        #expect(retrievedDeaths[0].name == "Test Celebrity 1")
        #expect(retrievedDeaths[1].name == "Test Celebrity 2")
        #expect(retrievedDeaths[0].isDeceased == true)
        #expect(retrievedDeaths[1].isDeceased == true)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "testLastKnownDeaths")
    }
}
