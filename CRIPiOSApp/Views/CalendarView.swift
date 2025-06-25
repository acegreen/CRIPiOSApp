//
//  CalendarView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import SwiftUI

struct CalendarView: View {
    @Binding var viewModel: CalendarViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    @State private var showingAddEvent = false
    @State private var calendarService = CalendarService.shared
    @State private var showingCalendarPermission = false
    @State private var showingEventDetails = false
    @State private var selectedEvent: CalendarEvent?
    @State private var cachedEvents: [Date: [CalendarEvent]] = [:]
    @State private var isLoadingEvents = false
    @State private var currentLoadingTask: Task<Void, Never>?
    
    init(viewModel: Binding<CalendarViewModel>, 
         celebrityViewModel: Binding<CelebrityViewModel>,
         socialViewModel: Binding<SocialViewModel>) {
        self._viewModel = viewModel
        self._celebrityViewModel = celebrityViewModel
        self._socialViewModel = socialViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: viewModel.previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.monthYearString)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: viewModel.nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        // Day headers
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        
                        // Calendar days
                        ForEach(viewModel.getDaysInMonth(), id: \.self) { date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    events: cachedEvents[date] ?? [],
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                                ) {
                                    viewModel.selectedDate = date
                                }
                            } else {
                                Color.clear
                                    .frame(height: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Events for selected date
                ScrollView {
                    LazyVStack(spacing: 12) {
                        let selectedDateEvents = cachedEvents[viewModel.selectedDate] ?? []
                        if selectedDateEvents.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No events on \(viewModel.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.headline)
                                Text("Celebrity birthdays and death anniversaries will appear here")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(selectedDateEvents, id: \.id) { event in
                                CalendarEventRow(event: event) {
                                    // Fetch fresh celebrity data before showing details
                                    Task {
                                        if let freshCelebrity = celebrityViewModel.fetchCelebrities().first(where: { $0.id == event.celebrity.id }) {
                                            let freshEvent = CalendarEvent(
                                                id: event.id,
                                                celebrity: freshCelebrity,
                                                type: event.type,
                                                date: event.date
                                            )
                                            await MainActor.run {
                                                selectedEvent = freshEvent
                                                showingEventDetails = true
                                            }
                                        } else {
                                            // Fallback to original event if fresh data not found
                                            await MainActor.run {
                                                selectedEvent = event
                                                showingEventDetails = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        viewModel.goToToday()
                    }
                    .foregroundColor(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if calendarService.isAuthorized {
                            addAllEventsToCalendar()
                        } else {
                            showingCalendarPermission = true
                        }
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingCalendarPermission) {
                CalendarPermissionView(calendarService: calendarService)
            }
            .sheet(isPresented: $showingEventDetails) {
                if let event = selectedEvent {
                    NavigationView {
                        CelebrityDetailView(
                            celebrity: event.celebrity,
                            viewModel: celebrityViewModel,
                            socialViewModel: socialViewModel
                        )
                        .task {
                            // Fetch a fresh copy of the celebrity from the database
                            // to ensure all properties are properly loaded
                            if let freshCelebrity = celebrityViewModel.fetchCelebrities().first(where: { $0.id == event.celebrity.id }) {
                                // Update the selected event with the fresh celebrity data
                                selectedEvent = CalendarEvent(
                                    id: event.id,
                                    celebrity: freshCelebrity,
                                    type: event.type,
                                    date: event.date
                                )
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadEventsForCurrentMonth()
            }
            .onChange(of: viewModel.selectedDate) { _, newDate in
                // Only reload events if the month actually changes
                if !viewModel.isSameMonth(viewModel.selectedDate, newDate) {
                    loadEventsForCurrentMonth()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .calendarMonthChanged)) { _ in
                // Explicitly reload events when month changes via navigation buttons
                DispatchQueue.main.async {
                    loadEventsForCurrentMonth()
                }
            }
            .onDisappear {
                // Cancel any pending loading tasks when view disappears
                currentLoadingTask?.cancel()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadEventsForCurrentMonth() {
        // Cancel any existing loading task
        currentLoadingTask?.cancel()
        
        // Create a new task for loading events
        currentLoadingTask = Task {
            await MainActor.run {
                isLoadingEvents = true
            }
            
            // Capture the current selected date to ensure we're loading for the right month
            let targetDate = viewModel.selectedDate
            
            do {
                let celebrities = await loadCelebritiesAsync()
                
                // Check if task was cancelled
                try Task.checkCancellation()
                
                let events = await calculateEventsForMonth(celebrities: celebrities, targetDate: targetDate)
                
                // Check if task was cancelled again
                try Task.checkCancellation()
                
                await MainActor.run {
                    // Only update if this is still the current month
                    if viewModel.isSameMonth(targetDate, viewModel.selectedDate) {
                        cachedEvents = events
                    }
                    isLoadingEvents = false
                }
            } catch {
                // Task was cancelled or failed
                await MainActor.run {
                    isLoadingEvents = false
                }
            }
        }
    }
    
    private func loadCelebritiesAsync() async -> [Celebrity] {
        return await Task.detached {
            return celebrityViewModel.fetchCelebrities()
        }.value
    }
    
    private func calculateEventsForMonth(celebrities: [Celebrity], targetDate: Date) async -> [Date: [CalendarEvent]] {
        return await Task.detached {
            var events: [Date: [CalendarEvent]] = [:]
            let calendar = Calendar.current
            
            // Get the date range for the target month view
            let startOfMonth = calendar.dateInterval(of: .month, for: targetDate)?.start ?? targetDate
            let firstWeekday = calendar.component(.weekday, from: startOfMonth)
            let daysInMonth = calendar.range(of: .day, in: .month, for: targetDate)?.count ?? 30
            
            // Calculate start and end dates for the grid (including previous month's days)
            let gridStartDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: startOfMonth) ?? startOfMonth
            let gridEndDate = calendar.date(byAdding: .day, value: 41, to: gridStartDate) ?? startOfMonth // 6 weeks * 7 days - 1
            
            // Generate all dates in the grid
            var currentDate = gridStartDate
            while currentDate <= gridEndDate {
                let dayEvents = viewModel.getEventsForDate(currentDate, celebrities: celebrities)
                if !dayEvents.isEmpty {
                    events[currentDate] = dayEvents
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            return events
        }.value
    }
    
    private func addAllEventsToCalendar() {
        Task {
            let celebrities = await loadCelebritiesAsync()
            _ = await calendarService.addAllCelebrityEvents(celebrities: celebrities)
            
            await MainActor.run {
                // Calendar events added successfully
            }
        }
    }
}

// MARK: - Supporting Views

struct CalendarDayView: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if !events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(events.prefix(3), id: \.id) { event in
                            Circle()
                                .fill(event.type.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension CalendarDayView: Equatable {
    static func == (lhs: CalendarDayView, rhs: CalendarDayView) -> Bool {
        return lhs.date == rhs.date && 
               lhs.isSelected == rhs.isSelected && 
               lhs.events.count == rhs.events.count
    }
}

struct CalendarEventRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(event.type.color)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(event.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension CalendarEventRow: Equatable {
    static func == (lhs: CalendarEventRow, rhs: CalendarEventRow) -> Bool {
        return lhs.event.id == rhs.event.id
    }
}

struct CalendarEventDetailView: View {
    let event: CalendarEvent
    let calendarService: CalendarService
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingToCalendar = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Event Icon
                Image(systemName: event.type.icon)
                    .font(.system(size: 60))
                    .foregroundColor(event.type.color)
                
                // Event Details
                VStack(spacing: 16) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(event.subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(event.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text(event.date.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Add to Calendar") {
                        addEventToCalendar()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isAddingToCalendar)
                    
                    if isAddingToCalendar {
                        ProgressView("Adding to calendar...")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addEventToCalendar() {
        isAddingToCalendar = true
        
        Task {
            let success: Bool
            
            switch event.type {
            case .birthday:
                success = await calendarService.addBirthdayEvent(for: event.celebrity)
            case .deathAnniversary:
                success = await calendarService.addDeathAnniversaryEvent(for: event.celebrity)
            }
            
            await MainActor.run {
                isAddingToCalendar = false
                if success {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Models

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let celebrity: Celebrity
    let type: CalendarEventType
    let date: Date
    
    var title: String {
        switch type {
        case .birthday:
            return "🎂 \(celebrity.name)'s Birthday"
        case .deathAnniversary:
            return "🕯️ \(celebrity.name) Death Anniversary"
        }
    }
    
    var subtitle: String {
        celebrity.occupation
    }
    
    var description: String {
        switch type {
        case .birthday:
            return "Celebrating \(celebrity.name)'s birthday. They are \(celebrity.age) years old."
        case .deathAnniversary:
            return "Remembering \(celebrity.name) on the anniversary of their passing. \(celebrity.causeOfDeath ?? "Cause of death unknown.")"
        }
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

enum CalendarEventType: Equatable {
    case birthday
    case deathAnniversary
    
    var icon: String {
        switch self {
        case .birthday: return "gift.fill"
        case .deathAnniversary: return "heart.slash.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .birthday: return .pink
        case .deathAnniversary: return .red
        }
    }
} 

