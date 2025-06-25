//
//  PersonalTimelineView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import SwiftUI

struct PersonalTimelineView: View {
    @Binding var timelineViewModel: TimelineViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    @State private var selectedTimeframe: TimelineTimeframe = .month
    @State private var selectedFilter: TimelineFilter = .all
    @State private var isLoading = false
    
    init(timelineViewModel: Binding<TimelineViewModel>, 
         celebrityViewModel: Binding<CelebrityViewModel>,
         socialViewModel: Binding<SocialViewModel>) {
        self._timelineViewModel = timelineViewModel
        self._celebrityViewModel = celebrityViewModel
        self._socialViewModel = socialViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with filters
                VStack(spacing: 12) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(TimelineTimeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Filter picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TimelineFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    icon: filter.icon,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Timeline content
                if socialViewModel.isLoggedIn {
                    if isLoading {
                        Spacer()
                        ProgressView("Loading timeline...")
                        Spacer()
                    } else {
                        TimelineContent(
                            timelineViewModel: $timelineViewModel,
                            celebrityViewModel: $celebrityViewModel,
                            socialViewModel: $socialViewModel,
                            timeframe: selectedTimeframe,
                            filter: selectedFilter
                        )
                    }
                } else {
                    SignInPrompt()
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTimelineData()
            }
            .onChange(of: selectedTimeframe) { _ in
                loadTimelineData()
            }
            .onChange(of: selectedFilter) { _ in
                loadTimelineData()
            }
        }
    }
    
    private func loadTimelineData() {
        guard socialViewModel.isLoggedIn else { return }
        
        isLoading = true
        
        Task {
            // Simulate loading time for better UX
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct TimelineContent: View {
    @Binding var timelineViewModel: TimelineViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    let timeframe: TimelineTimeframe
    let filter: TimelineFilter
    
    var timelineEvents: [TimelineEvent] {
        let celebrities = celebrityViewModel.fetchCelebrities()
        let tributes = socialViewModel.fetchRecentTributes()
        return timelineViewModel.getTimelineEvents(
            timeframe: timeframe, 
            filter: filter, 
            celebrities: celebrities, 
            tributes: tributes
        )
    }
    
    var body: some View {
        if timelineEvents.isEmpty {
            EmptyTimelineView(filter: filter)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(timelineEvents) { event in
                        TimelineEventCard(event: event)
                    }
                }
                .padding()
            }
        }
    }
}

struct TimelineEventCard: View {
    let event: TimelineEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Event icon
                Image(systemName: event.type.icon)
                    .foregroundColor(event.type.color)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(event.type.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(event.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Relevance indicator
                if event.relevance > 0.7 {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                // Date
                Text(event.date.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Relevance bar
            HStack {
                Text("Relevance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: event.relevance)
                    .progressViewStyle(LinearProgressViewStyle(tint: event.type.color))
                
                Text("\(Int(event.relevance * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyTimelineView: View {
    let filter: TimelineFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "timeline.selection")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No \(filter.rawValue.lowercased()) events")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("There are no \(filter.rawValue.lowercased()) events in your timeline for the selected timeframe.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SignInPrompt: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Sign In to View Timeline")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Create an account or sign in to see your personalized celebrity timeline based on your interests.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
