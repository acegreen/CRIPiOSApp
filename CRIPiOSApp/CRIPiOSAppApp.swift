//
//  CRIPiOSAppApp.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI
import BackgroundTasks
import SwiftData

@main
struct CRIPiOSAppApp: App {
    @State private var celebrityViewModel: CelebrityViewModel
    @State private var socialViewModel: SocialViewModel
    @State private var gamificationViewModel: GamificationViewModel
    @State private var timelineViewModel: TimelineViewModel
    @State private var calendarViewModel: CalendarViewModel
    @State private var analyticsViewModel: AnalyticsViewModel
    @State private var settingsViewModel: SettingsViewModel
    @State private var cronService = CronService.shared
    
    init() {
        // Initialize and start the CRON service
        CronService.shared.startCronService()
        
        // Initialize view models independently (no circular dependencies)
        self.socialViewModel = SocialViewModel()
        self.celebrityViewModel = CelebrityViewModel()
        self.gamificationViewModel = GamificationViewModel()
        self.timelineViewModel = TimelineViewModel()
        self.calendarViewModel = CalendarViewModel()
        self.analyticsViewModel = AnalyticsViewModel()
        self.settingsViewModel = SettingsViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                celebrityViewModel: $celebrityViewModel,
                socialViewModel: $socialViewModel,
                timelineViewModel: $timelineViewModel,
                calendarViewModel: $calendarViewModel,
                analyticsViewModel: $analyticsViewModel,
                settingsViewModel: $settingsViewModel,
                gamificationViewModel: $gamificationViewModel
            )
        }
        .modelContainer(for: [
            Celebrity.self, 
            UserProfile.self, 
            Tribute.self, 
            Discussion.self, 
            Comment.self, 
            Follow.self, 
            Like.self, 
            WatchlistItem.self, 
            AppNotification.self,
            Achievement.self,
            TriviaQuestion.self,
            Prediction.self,
            UserProgress.self,
            CelebrityMedia.self,
            CelebrityQuote.self,
            CareerHighlight.self,
            CelebrityBiography.self,
            CelebrityAnalytics.self
        ])
    }
}

struct ContentView: View {
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    @Binding var timelineViewModel: TimelineViewModel
    @Binding var calendarViewModel: CalendarViewModel
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var settingsViewModel: SettingsViewModel
    @Binding var gamificationViewModel: GamificationViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var cronService = CronService.shared
    
    var body: some View {
        MainTabView(
            celebrityViewModel: $celebrityViewModel,
            socialViewModel: $socialViewModel,
            timelineViewModel: $timelineViewModel,
            calendarViewModel: $calendarViewModel,
            analyticsViewModel: $analyticsViewModel,
            settingsViewModel: $settingsViewModel,
            gamificationViewModel: $gamificationViewModel
        )
        .onAppear {
            // Set the model context for all view models
            celebrityViewModel.setModelContext(modelContext)
            socialViewModel.setModelContext(modelContext)
            timelineViewModel.setModelContext(modelContext)
            calendarViewModel.setModelContext(modelContext)
            analyticsViewModel.setModelContext(modelContext)
            settingsViewModel.setModelContext(modelContext)
            gamificationViewModel.setModelContext(modelContext)
            cronService.setAppActive(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            cronService.setAppActive(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            cronService.setAppActive(false)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            cronService.setAppActive(false)
        }
        .sheet(isPresented: $cronService.showingDeathAlert) {
            DeathAlertView(
                celebrities: cronService.deathAlertCelebrities
            ) {
                cronService.dismissDeathAlert()
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
