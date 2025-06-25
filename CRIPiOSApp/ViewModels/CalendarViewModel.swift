//
//  CalendarViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

extension Notification.Name {
    static let calendarMonthChanged = Notification.Name("calendarMonthChanged")
}

@Observable
class CalendarViewModel {
    private var modelContext: ModelContext?
    var selectedDate: Date 
    var events: [CalendarEvent] = []
    var isLoading = false
    var errorMessage: String?
    
    private let calendar = Calendar.current
    private var cachedMonthDays: [Date: [Date?]] = [:]
    private var cachedMonthKey: Date?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        self.selectedDate = Date()
    }
    
    // MARK: - Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Public Methods
    
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            // Trigger event loading for the new month
            NotificationCenter.default.post(name: .calendarMonthChanged, object: newDate)
        }
    }
    
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            // Trigger event loading for the new month
            NotificationCenter.default.post(name: .calendarMonthChanged, object: newDate)
        }
    }
    
    func goToToday() {
        selectedDate = Date()
    }
    
    func reloadData() {
        // This method is now handled by the view
    }
    
    func getEventsForDate(_ date: Date, celebrities: [Celebrity]) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        
        for celebrity in celebrities {
            // Check birthdays
            if let birthDate = celebrity.birthDateValue {
                let nextBirthday = getNextBirthday(from: birthDate, referenceDate: date)
                if calendar.isDate(nextBirthday, inSameDayAs: date) {
                    events.append(CalendarEvent(
                        id: "\(celebrity.id)-birthday",
                        celebrity: celebrity,
                        type: .birthday,
                        date: nextBirthday
                    ))
                }
            }
            
            // Check death anniversaries
            if celebrity.isDeceased, let deathDate = celebrity.deathDateValue {
                let nextAnniversary = getNextAnniversary(from: deathDate, referenceDate: date)
                if calendar.isDate(nextAnniversary, inSameDayAs: date) {
                    events.append(CalendarEvent(
                        id: "\(celebrity.id)-anniversary",
                        celebrity: celebrity,
                        type: .deathAnniversary,
                        date: nextAnniversary
                    ))
                }
            }
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    func getDaysInMonth() -> [Date?] {
        // Create a cache key for the current month
        let monthKey = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        
        // Check if we have cached data for this month
        if let cachedDays = cachedMonthDays[monthKey] {
            return cachedDays
        }
        
        // Calculate days for the month
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Cache the result
        cachedMonthDays[monthKey] = days
        
        // Keep cache size manageable (keep last 3 months)
        if cachedMonthDays.count > 3 {
            let sortedKeys = cachedMonthDays.keys.sorted()
            if sortedKeys.count > 3 {
                for key in sortedKeys.dropLast(sortedKeys.count - 3) {
                    cachedMonthDays.removeValue(forKey: key)
                }
            }
        }
        
        return days
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    // MARK: - Private Methods
    
    private func getNextBirthday(from birthDate: Date, referenceDate: Date) -> Date {
        let referenceYear = calendar.component(.year, from: referenceDate)
        
        // Get the month and day components from the birth date
        let birthMonth = calendar.component(.month, from: birthDate)
        let birthDay = calendar.component(.day, from: birthDate)
        
        // Get the reference month and day
        let referenceMonth = calendar.component(.month, from: referenceDate)
        let referenceDay = calendar.component(.day, from: referenceDate)
        
        // Determine which year to use for the next birthday
        var targetYear = referenceYear
        
        // If the birthday has already passed in the reference year, use next year
        if birthMonth < referenceMonth || (birthMonth == referenceMonth && birthDay < referenceDay) {
            targetYear = referenceYear + 1
        }
        
        // Create the next birthday date
        let nextBirthday = calendar.date(from: DateComponents(year: targetYear, month: birthMonth, day: birthDay)) ?? birthDate
        
        return nextBirthday
    }
    
    private func getNextAnniversary(from deathDate: Date, referenceDate: Date) -> Date {
        let referenceYear = calendar.component(.year, from: referenceDate)
        
        // Get the month and day components from the death date
        let deathMonth = calendar.component(.month, from: deathDate)
        let deathDay = calendar.component(.day, from: deathDate)
        
        // Get the reference month and day
        let referenceMonth = calendar.component(.month, from: referenceDate)
        let referenceDay = calendar.component(.day, from: referenceDate)
        
        // Determine which year to use for the next anniversary
        var targetYear = referenceYear
        
        // If the anniversary has already passed in the reference year, use next year
        if deathMonth < referenceMonth || (deathMonth == referenceMonth && deathDay < referenceDay) {
            targetYear = referenceYear + 1
        }
        
        // Create the next anniversary date
        let nextAnniversary = calendar.date(from: DateComponents(year: targetYear, month: deathMonth, day: deathDay)) ?? deathDate
        
        return nextAnniversary
    }
} 