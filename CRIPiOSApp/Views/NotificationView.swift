//
//  NotificationView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct NotificationView: View {
    let socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if socialViewModel.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("You're all caught up! Check back later for updates.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(socialViewModel.notifications, id: \.id) { notification in
                            NotificationRowView(notification: notification,
                                                socialViewModel: socialViewModel)
                        }
                        .onDelete(perform: deleteNotifications)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            socialViewModel.markAllNotificationsAsRead()
                        }) {
                            Label("Mark All as Read", systemImage: "checkmark.circle")
                        }
                        
                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Clear All Notifications", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllNotifications()
                }
            } message: {
                Text("This will permanently delete all your notifications. This action cannot be undone.")
            }
        }
    }
    
    private func deleteNotifications(offsets: IndexSet) {
        for index in offsets {
            let notification = socialViewModel.notifications[index]
            socialViewModel.deleteNotification(notification)
        }
    }
    
    private func clearAllNotifications() {
        for notification in socialViewModel.notifications {
            socialViewModel.deleteNotification(notification)
        }
    }
}

struct NotificationRowView: View {
    let notification: AppNotification
    let socialViewModel: SocialViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Notification Icon
            ZStack {
                Circle()
                    .fill(Color(notification.type.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(notification.type.color))
            }
            
            // Notification Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(notification.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Read/Unread Indicator
            if !notification.isRead {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if !notification.isRead {
                socialViewModel.markNotificationAsRead(notification)
            }
        }
    }
}

#Preview {
    NotificationView(socialViewModel: SocialViewModel())
} 
