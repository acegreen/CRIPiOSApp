//
//  CalendarPermissionView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import SwiftUI

struct CalendarPermissionView: View {
    let calendarService: CalendarService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Calendar Access")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Allow CRIP to add celebrity birthdays and death anniversaries to your calendar?")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    Button("Allow Access") {
                        Task {
                            let granted = await calendarService.requestAccess()
                            if granted {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Not Now") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Calendar Permission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 