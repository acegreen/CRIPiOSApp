//
//  SettingsViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class SettingsViewModel {
    private var modelContext: ModelContext?
    
    // Services
    private let cronService = CronService.shared
    private let exportService = ExportService.shared
//    private let cloudBackupService = CloudBackupService.shared
    
    // State
    var isPerformingDeathCheck = false
    var lastDeathCheckDate: Date = Date.distantPast
    var selectedExportFormat: ExportService.ExportFormat = .json
    var exportFileURL: URL?
    var isExporting = false
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - SwiftData Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Background Death Checks
    
    func updateCronFrequency(_ frequency: CronFrequency) {
        cronService.updateFrequency(frequency)
    }
    
    func performManualDeathCheck() async {
        guard !isPerformingDeathCheck else { return }
        
        isPerformingDeathCheck = true
        
        do {
            // Simulate death check process
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Update last check date
            lastDeathCheckDate = Date()
            
        } catch {
            print("❌ Error performing death check: \(error)")
        }
        
        isPerformingDeathCheck = false
    }
    
    // MARK: - Export Functionality
    
    func exportData(format: ExportService.ExportFormat, userProfile: UserProfile?, celebrities: [Celebrity], tributes: [Tribute], watchlist: [WatchlistItem]) async -> URL? {
        guard let currentUser = userProfile else { return nil }
        
        isExporting = true
        
        do {
            let url = await exportService.exportUserData(
                userProfile: currentUser,
                celebrities: celebrities,
                tributes: tributes,
                watchlist: watchlist,
                format: format
            )
            
            exportFileURL = url
            isExporting = false
            return url
            
        } catch {
            print("❌ Error exporting data: \(error)")
            isExporting = false
            return nil
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Sample Data Management
    
    var sampleProfiles: [UserProfile] {
        return UserProfile.sampleProfiles
    }
    
    // MARK: - Debug Functions
    
    func testSophiaLeoneDeath() {
        // Test function for death detection
        print("🧪 Testing Sophia Leone death detection...")
    }
    
    func testFullDeathCheckProcess() {
        // Test function for full death check process
        print("🧪 Testing full death check process...")
    }
    
    func testInAppAlert() {
        // Test function for in-app death alert
        print("🧪 Testing in-app death alert...")
    }
    
    func testBackgroundDeathAlert() {
        // Test function for background death alert
        print("🧪 Testing background death alert...")
    }
} 
