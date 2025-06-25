//
//  MainTabView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    @Binding var timelineViewModel: TimelineViewModel
    @Binding var calendarViewModel: CalendarViewModel
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var settingsViewModel: SettingsViewModel
    @Binding var gamificationViewModel: GamificationViewModel

    init(celebrityViewModel: Binding<CelebrityViewModel>,
         socialViewModel: Binding<SocialViewModel>,
         timelineViewModel: Binding<TimelineViewModel>,
         calendarViewModel: Binding<CalendarViewModel>,
         analyticsViewModel: Binding<AnalyticsViewModel>,
         settingsViewModel: Binding<SettingsViewModel>,
         gamificationViewModel: Binding<GamificationViewModel>) {
        self._celebrityViewModel = celebrityViewModel
        self._socialViewModel = socialViewModel
        self._timelineViewModel = timelineViewModel
        self._calendarViewModel = calendarViewModel
        self._analyticsViewModel = analyticsViewModel
        self._settingsViewModel = settingsViewModel
        self._gamificationViewModel = gamificationViewModel
    }

    var body: some View {
        TabView {
            CelebrityListView(
                viewModel: $celebrityViewModel,
                socialViewModel: $socialViewModel,
                settingsViewModel: $settingsViewModel
            )
            .tabItem {
                Image(systemName: "person.3.fill")
                Text("Celebrities")
            }

            SocialFeedView(viewModel: $socialViewModel)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Social")
                }

            PersonalTimelineView(
                timelineViewModel: $timelineViewModel,
                celebrityViewModel: $celebrityViewModel,
                socialViewModel: $socialViewModel
            )
            .tabItem {
                Image(systemName: "timeline.selection")
                Text("Timeline")
            }

            CalendarView(
                viewModel: $calendarViewModel,
                celebrityViewModel: $celebrityViewModel,
                socialViewModel: $socialViewModel
            )
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }

            AnalyticsDashboardView(
                viewModel: $analyticsViewModel,
                celebrityViewModel: $celebrityViewModel
            )
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Analytics")
            }

            //            SettingsView(
            //                settingsViewModel: $settingsViewModel,
            //                celebrityViewModel: $celebrityViewModel,
            //                socialViewModel: $socialViewModel
            //            )
            //            .tabItem {
            //                Image(systemName: "gear")
            //                Text("Settings")
            //            }

            //            WatchlistView(socialViewModel: $socialViewModel)
            //                .tabItem {
            //                    Image(systemName: "heart.fill")
            //                    Text("Watchlist")
            //                }
            //
            //            GamificationView(gamificationViewModel: $gamificationViewModel)
            //                .tabItem {
            //                    Image(systemName: "gamecontroller.fill")
            //                    Text("Games")
            //                }
            //
            //            StatisticsView(viewModel: $celebrityViewModel)
            //                .tabItem {
            //                    Image(systemName: "chart.bar.fill")
            //                    Text("Statistics")
            //                }
            //
            //            InsightsView(viewModel: $celebrityViewModel)
            //                .tabItem {
            //                    Image(systemName: "brain.head.profile")
            //                    Text("Insights")
            //                }
        }
    }
}
