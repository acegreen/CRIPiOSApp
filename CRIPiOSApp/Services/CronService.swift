//
//  CronService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import BackgroundTasks
import UserNotifications
import Observation

enum CronFrequency: String, CaseIterable {
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case disabled = "disabled"
    
    var displayName: String {
        switch self {
        case .hourly: return "Every Hour"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .disabled: return "Disabled"
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .hourly: return 3600 // 1 hour
        case .daily: return 86400 // 24 hours
        case .weekly: return 604800 // 7 days
        case .monthly: return 2592000 // 30 days
        case .disabled: return nil
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let deathCheckCompleted = Notification.Name("deathCheckCompleted")
    static let newDeathsDetected = Notification.Name("newDeathsDetected")
}

class CronService {
    static var shared = CronService()
    
    @Published var showingDeathAlert = false
    @Published var deathAlertCelebrities: [Celebrity] = []
    @Published var lastDeathCheck: Date = Date.distantPast
    
    private var celebrityViewModel: CelebrityViewModel?
    private let deathCheckService = DeathCheckService()
    private var cronFrequency: CronFrequency = .daily
    var isAppActive = false
    private var notificationsEnabled = true
    
    init() {
        setupBackgroundTasks()
        requestNotificationPermissions()
    }
    
    func setCelebrityViewModel(_ celebrityViewModel: CelebrityViewModel) {
        self.celebrityViewModel = celebrityViewModel
        deathCheckService.setCelebrityViewModel(celebrityViewModel)
    }
    
    // MARK: - Public Methods
    
    func startCronService() {
        guard cronFrequency != .disabled else { 
            return 
        }
        
        // Try to schedule background task first
        scheduleBackgroundTask()
        
        // Also start local timer for immediate testing
        startLocalTimer()
    }
    
    func stopCronService() {
        stopLocalTimer()
        cancelBackgroundTask()
    }
    
    func updateFrequency(_ frequency: CronFrequency) {
        cronFrequency = frequency
        
        if frequency == .disabled {
            stopCronService()
        } else {
            startCronService()
        }
    }
    
    func performManualDeathCheck() async {
        await performDeathCheck()
    }
    
    // MARK: - In-App Alert Methods
    
    func setAppActive(_ active: Bool) {
        isAppActive = active
    }
    
    func dismissDeathAlert() {
        showingDeathAlert = false
        deathAlertCelebrities = []
    }
    
    // MARK: - Private Methods
    
    private func setupBackgroundTasks() {
        // Register background task with better error handling
        do {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.cripiosapp.deathcheck", using: nil) { task in
                self.handleBackgroundTask(task as! BGAppRefreshTask)
            }
            print("✅ Background task registered successfully")
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permissions granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error)")
                } else {
                    print("⚠️ Notification permissions denied by user")
                }
            }
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.cripiosapp.deathcheck")
        
        if let timeInterval = cronFrequency.timeInterval {
            request.earliestBeginDate = Date(timeIntervalSinceNow: timeInterval)
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background task scheduled successfully")
        } catch {
            print("❌ Failed to schedule background task: \(error)")
            print("💡 This is normal on simulator or when background refresh is disabled")
            
            // Fallback: Use local timer for testing
            if cronFrequency != .disabled {
                print("🔄 Falling back to local timer for testing")
                startLocalTimer()
            }
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule the next background task
        scheduleBackgroundTask()
        
        // Create a task to track background execution
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform the death check
        Task {
            await performDeathCheck()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func startPeriodicTimer() {
        guard let timeInterval = cronFrequency.timeInterval else { return }
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            Task {
                await self.performDeathCheck()
            }
        }
    }
    
    private func stopPeriodicTimer() {
        // Timer will be invalidated when app goes to background
    }
    
    private func cancelBackgroundTask() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.cripiosapp.deathcheck")
    }
    
    private func startLocalTimer() {
        guard let timeInterval = cronFrequency.timeInterval else { return }
        
        // Cancel any existing timer
        stopLocalTimer()
        
        // Start new timer
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            Task {
                await self.performDeathCheck()
            }
        }
    }
    
    private func stopLocalTimer() {
        // Timer will be invalidated when app goes to background
    }
    
    private func performDeathCheck() async {
        guard cronFrequency != .disabled else { return }
        
        lastDeathCheck = Date()
        
        let newDeaths = await deathCheckService.checkForNewDeaths()
        
        if !newDeaths.isEmpty {
            // Show in-app alert if user is active, otherwise send push notifications
            if isAppActive {
                await MainActor.run {
                    self.deathAlertCelebrities = newDeaths
                    self.showingDeathAlert = true
                }
            } else if notificationsEnabled {
                await sendDeathNotifications(for: newDeaths)
            }
        }
        
        // Update the view model and save to SwiftData
        await MainActor.run {
            // Update SwiftData with new death information
            if let viewModel = celebrityViewModel {
                viewModel.updateCelebritiesFromDeathCheck(newDeaths)
                viewModel.refreshCelebrities()
            }
        }
        
        // Post notification that death check is completed
        await MainActor.run {
            NotificationCenter.default.post(name: .deathCheckCompleted, object: nil)
            if !newDeaths.isEmpty {
                NotificationCenter.default.post(name: .newDeathsDetected, object: newDeaths)
            }
        }
    }
    
    private func sendDeathNotifications(for celebrities: [Celebrity]) async {
        let content = UNMutableNotificationContent()
        content.title = "Celebrity Death Alert"
        content.sound = .default
        
        for celebrity in celebrities {
            content.body = "\(celebrity.name) has passed away"
            content.subtitle = celebrity.occupation
            
            let request = UNNotificationRequest(
                identifier: "death-\(celebrity.id)",
                content: content,
                trigger: nil
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Death notification sent for \(celebrity.name)")
            } catch {
                print("Failed to send notification for \(celebrity.name): \(error)")
            }
        }
    }
} 
