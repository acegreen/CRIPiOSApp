//
//  TimelineViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class TimelineViewModel {
    private var modelContext: ModelContext?
    var isLoading = false
    var errorMessage: String?
    var userInterests: UserInterests = UserInterests()
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadUserInterests()
    }
    
    // MARK: - Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
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
    
    // MARK: - Timeline Methods
    
    func getTimelineEvents(timeframe: TimelineTimeframe, filter: TimelineFilter, celebrities: [Celebrity], tributes: [Tribute]) -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        
        // Get user's interests
        let userInterests = self.userInterests.selectedInterests.union(Set(self.userInterests.customInterests))
        
        // Add death events
        if filter == .all || filter == .deaths {
            let recentDeaths = celebrities.filter { $0.isDeceased && $0.deathDateValue != nil }
                .sorted { $0.deathDateValue! > $1.deathDateValue! }
            
            for death in recentDeaths {
                if let deathDate = death.deathDateValue {
                    let daysAgo = Calendar.current.dateComponents([.day], from: deathDate, to: Date()).day ?? 0
                    
                    if shouldIncludeEvent(daysAgo: daysAgo, timeframe: timeframe) {
                        events.append(TimelineEvent(
                            id: UUID(),
                            type: .death,
                            title: "\(death.name) passed away",
                            subtitle: death.occupation,
                            description: death.causeOfDeath ?? "No cause of death reported",
                            date: deathDate,
                            celebrity: death,
                            relevance: calculateRelevance(celebrity: death, userInterests: userInterests) ?? 0.5
                        ))
                    }
                }
            }
        }
        
        // Add birthday events
        if filter == .all || filter == .birthdays {
            for celebrity in celebrities {
                if let birthDate = celebrity.birthDateValue {
                    let daysAgo = Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
                    
                    if shouldIncludeEvent(daysAgo: daysAgo, timeframe: timeframe) {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        
                        events.append(TimelineEvent(
                            id: UUID(),
                            type: .birthday,
                            title: "\(celebrity.name)'s birthday",
                            subtitle: "\(celebrity.age) years old",
                            description: "Born on \(dateFormatter.string(from: birthDate))",
                            date: birthDate,
                            celebrity: celebrity,
                            relevance: calculateRelevance(celebrity: celebrity, userInterests: userInterests) ?? 0.5
                        ))
                    }
                }
            }
        }
        
        // Add career milestone events (simulated)
        if filter == .all || filter == .career {
            for celebrity in celebrities {
                if let relevance = calculateRelevance(celebrity: celebrity, userInterests: userInterests), relevance > 0.3 {
                    // Simulate career milestones with more realistic dates
                    let milestoneDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...90), to: Date()) ?? Date()
                    let daysAgo = Calendar.current.dateComponents([.day], from: milestoneDate, to: Date()).day ?? 0
                    
                    if shouldIncludeEvent(daysAgo: daysAgo, timeframe: timeframe) {
                        let milestones = [
                            "Released new album",
                            "Starred in blockbuster movie",
                            "Won prestigious award",
                            "Started new TV series",
                            "Published autobiography",
                            "Announced retirement",
                            "Made comeback",
                            "Signed major contract",
                            "Launched new business",
                            "Received lifetime achievement award"
                        ]
                        
                        events.append(TimelineEvent(
                            id: UUID(),
                            type: .career,
                            title: "\(celebrity.name) \(milestones.randomElement() ?? "achieved milestone")",
                            subtitle: celebrity.occupation,
                            description: "Career milestone for \(celebrity.name) in \(celebrity.occupation.lowercased())",
                            date: milestoneDate,
                            celebrity: celebrity,
                            relevance: relevance
                        ))
                    }
                }
            }
        }
        
        // Add social events
        if filter == .all || filter == .social {
            for tribute in tributes {
                let daysAgo = Calendar.current.dateComponents([.day], from: tribute.createdAt, to: Date()).day ?? 0
                
                if shouldIncludeEvent(daysAgo: daysAgo, timeframe: timeframe) {
                    events.append(TimelineEvent(
                        id: UUID(),
                        type: .social,
                        title: "New tribute for \(tribute.title)",
                        subtitle: "by \(tribute.celebrityName)",
                        description: tribute.title,
                        date: tribute.createdAt,
                        celebrity: celebrities.first { $0.name == tribute.celebrityName },
                        relevance: 0.7
                    ))
                }
            }
        }
        
        // Sort by date (most recent first) and then by relevance
        return events.sorted { event1, event2 in
            if event1.date == event2.date {
                return event1.relevance > event2.relevance
            }
            return event1.date > event2.date
        }
    }
    
    private func shouldIncludeEvent(daysAgo: Int, timeframe: TimelineTimeframe) -> Bool {
        guard let timeframeDays = timeframe.days else { return true }
        return daysAgo <= timeframeDays
    }
    
    private func calculateRelevance(celebrity: Celebrity, userInterests: Set<String>) -> Double? {
        if userInterests.isEmpty { return 0.5 }
        
        let matchingInterests = celebrity.interests.filter { userInterests.contains($0) }.count
        let totalInterests = celebrity.interests.count
        
        if totalInterests == 0 { return 0.3 }
        
        let baseRelevance = Double(matchingInterests) / Double(totalInterests)
        
        // Boost relevance for featured celebrities
        let featuredBonus = celebrity.isFeatured ? 0.2 : 0.0
        
        // Boost relevance for living celebrities (more current events)
        let livingBonus = !celebrity.isDeceased ? 0.1 : 0.0
        
        return min(baseRelevance + featuredBonus + livingBonus, 1.0)
    }
}

// MARK: - Timeline Models
struct TimelineEvent: Identifiable {
    let id: UUID
    let type: TimelineEventType
    let title: String
    let subtitle: String
    let description: String
    let date: Date
    let celebrity: Celebrity?
    let relevance: Double
    
    enum TimelineEventType {
        case death
        case birthday
        case career
        case social
        
        var icon: String {
            switch self {
            case .death: return "heart.slash.fill"
            case .birthday: return "gift.fill"
            case .career: return "star.fill"
            case .social: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .death: return .red
            case .birthday: return .pink
            case .career: return .orange
            case .social: return .blue
            }
        }
    }
}

enum TimelineTimeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"
    
    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        case .all: return nil
        }
    }
}

enum TimelineFilter: String, CaseIterable {
    case all = "All"
    case deaths = "Deaths"
    case birthdays = "Birthdays"
    case career = "Career"
    case social = "Social"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .deaths: return "heart.slash"
        case .birthdays: return "gift"
        case .career: return "star"
        case .social: return "person.2"
        }
    }
} 
