//
//  CalendarService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import EventKit
import SwiftUI

@Observable
class CalendarService {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    private var calendar: EKCalendar?
    
    var isAuthorized = false
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = authorizationStatus == .authorized
    }
    
    func requestAccess() async -> Bool {
        do {
            isAuthorized = try await eventStore.requestFullAccessToEvents()
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return isAuthorized
        } catch {
            print("❌ Calendar access denied: \(error)")
            return false
        }
    }
    
    // MARK: - Calendar Setup
    
    private func setupCalendar() -> EKCalendar? {
        // Check if our calendar already exists
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == "CRIP Celebrity Events" }) {
            return existingCalendar
        }
        
        // Create new calendar
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = "CRIP Celebrity Events"
        newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
        
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            print("❌ Failed to create calendar: \(error)")
            return nil
        }
    }
    
    // MARK: - Event Management
    
    func addBirthdayEvent(for celebrity: Celebrity) async -> Bool {
        guard isAuthorized else { return false }
        
        guard let birthDate = celebrity.birthDateValue else {
            print("❌ No birth date available for \(celebrity.name)")
            return false
        }
        
        let calendar = setupCalendar() ?? eventStore.defaultCalendarForNewEvents
        guard let calendar = calendar else { return false }
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = "🎂 \(celebrity.name)'s Birthday"
        event.notes = "Celebrity: \(celebrity.name)\nOccupation: \(celebrity.occupation)\nAge: \(celebrity.age)"
        
        // Set to next birthday
        let nextBirthday = getNextBirthday(from: birthDate)
        event.startDate = nextBirthday
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: nextBirthday) ?? nextBirthday
        
        // Make it recurring annually
        let recurrenceRule = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
        event.addRecurrenceRule(recurrenceRule)
        
        // Add alarm (1 day before)
        let alarm = EKAlarm(relativeOffset: -86400) // 24 hours before
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .futureEvents, commit: true)
            print("✅ Added birthday event for \(celebrity.name)")
            return true
        } catch {
            print("❌ Failed to add birthday event: \(error)")
            return false
        }
    }
    
    func addDeathAnniversaryEvent(for celebrity: Celebrity) async -> Bool {
        guard isAuthorized else { return false }
        
        guard let deathDate = celebrity.deathDateValue else {
            print("❌ No death date available for \(celebrity.name)")
            return false
        }
        
        let calendar = setupCalendar() ?? eventStore.defaultCalendarForNewEvents
        guard let calendar = calendar else { return false }
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = "🕯️ \(celebrity.name) Death Anniversary"
        event.notes = "In memory of \(celebrity.name)\nOccupation: \(celebrity.occupation)\nCause of Death: \(celebrity.causeOfDeath ?? "Unknown")"
        
        // Set to next death anniversary
        let nextAnniversary = getNextAnniversary(from: deathDate)
        event.startDate = nextAnniversary
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: nextAnniversary) ?? nextAnniversary
        
        // Make it recurring annually
        let recurrenceRule = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
        event.addRecurrenceRule(recurrenceRule)
        
        // Add alarm (1 day before)
        let alarm = EKAlarm(relativeOffset: -86400) // 24 hours before
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .futureEvents, commit: true)
            print("✅ Added death anniversary event for \(celebrity.name)")
            return true
        } catch {
            print("❌ Failed to add death anniversary event: \(error)")
            return false
        }
    }
    
    func removeEvents(for celebrity: Celebrity) async -> Bool {
        guard isAuthorized else { return false }
        
        let calendar = setupCalendar()
        guard let calendar = calendar else { return false }
        
        let startDate = Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date()
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let events = eventStore.events(matching: predicate)
        
        let celebrityEvents = events.filter { event in
            event.title?.contains(celebrity.name) == true
        }
        
        do {
            for event in celebrityEvents {
                try eventStore.remove(event, span: .futureEvents, commit: false)
            }
            try eventStore.commit()
            print("✅ Removed \(celebrityEvents.count) events for \(celebrity.name)")
            return true
        } catch {
            print("❌ Failed to remove events: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func getNextBirthday(from birthDate: Date) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get this year's birthday
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(bySetting: .year, value: thisYear, of: birthDate) ?? birthDate
        
        // If this year's birthday has passed, get next year's
        if nextBirthday < now {
            nextBirthday = calendar.date(bySetting: .year, value: thisYear + 1, of: birthDate) ?? birthDate
        }
        
        return nextBirthday
    }
    
    private func getNextAnniversary(from deathDate: Date) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get this year's anniversary
        let thisYear = calendar.component(.year, from: now)
        var nextAnniversary = calendar.date(bySetting: .year, value: thisYear, of: deathDate) ?? deathDate
        
        // If this year's anniversary has passed, get next year's
        if nextAnniversary < now {
            nextAnniversary = calendar.date(bySetting: .year, value: thisYear + 1, of: deathDate) ?? deathDate
        }
        
        return nextAnniversary
    }
    
    // MARK: - Bulk Operations
    
    func addAllCelebrityEvents(celebrities: [Celebrity]) async -> (birthdays: Int, anniversaries: Int) {
        guard isAuthorized else { return (0, 0) }
        
        var birthdayCount = 0
        var anniversaryCount = 0
        
        for celebrity in celebrities {
            if celebrity.birthDateValue != nil {
                if await addBirthdayEvent(for: celebrity) {
                    birthdayCount += 1
                }
            }
            
            if celebrity.isDeceased, celebrity.deathDateValue != nil {
                if await addDeathAnniversaryEvent(for: celebrity) {
                    anniversaryCount += 1
                }
            }
        }
        
        return (birthdayCount, anniversaryCount)
    }
    
    func removeAllCelebrityEvents(celebrities: [Celebrity]) async -> Int {
        guard isAuthorized else { return 0 }
        
        var removedCount = 0
        
        for celebrity in celebrities {
            if await removeEvents(for: celebrity) {
                removedCount += 1
            }
        }
        
        return removedCount
    }
} 