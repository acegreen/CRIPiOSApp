//
//  UserProfileView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct UserProfileView: View {
    @Binding var socialViewModel: SocialViewModel
    let user: UserProfile
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar and basic info
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 128, height: 128)
                            .overlay(
                                Text(String(user.displayName.prefix(1)))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        StatItem(value: "\(user.tributeCount)", label: "Tributes")
                        StatItem(value: "\(user.discussionCount)", label: "Discussions")
                        StatItem(value: "\(user.followerCount)", label: "Followers")
                        StatItem(value: "\(user.followingCount)", label: "Following")
                    }
                    
                    // Follow Button (if not current user)
                    if socialViewModel.currentUser?.id != user.id {
                        Button(action: {
                            socialViewModel.followUser(user)
                        }) {
                            Text(socialViewModel.isFollowing(user) ? "Following" : "Follow")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(socialViewModel.isFollowing(user) ? .primary : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(socialViewModel.isFollowing(user) ? Color(.systemGray4) : Color.accentColor)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                // Interests
                if !user.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(user.interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.accentColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Favorite Celebrities
                if !user.favoriteCelebrities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Favorite Celebrities")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(user.favoriteCelebrities, id: \.self) { celebrity in
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text(String(celebrity.prefix(1)))
                                                    .font(.headline)
                                                    .foregroundColor(.accentColor)
                                            )
                                        
                                        Text(celebrity)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Content Tabs
                VStack(spacing: 0) {
                    // Tab Picker
                    HStack(spacing: 0) {
                        TabButton(
                            title: "Tributes",
                            isSelected: selectedTab == 0,
                            action: { selectedTab = 0 }
                        )
                        
                        TabButton(
                            title: "Discussions",
                            isSelected: selectedTab == 1,
                            action: { selectedTab = 1 }
                        )
                        
                        TabButton(
                            title: "Watchlist",
                            isSelected: selectedTab == 2,
                            action: { selectedTab = 2 }
                        )
                    }
                    .background(Color(.systemGray6))
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        UserTributesView(
                            tributes: socialViewModel.fetchUserTributes(user.id),
                            socialViewModel: $socialViewModel
                        )
                        .tag(0)
                        
                        UserDiscussionsView(
                            discussions: socialViewModel.fetchUserDiscussions(user.id),
                            socialViewModel: $socialViewModel
                        )
                        .tag(1)
                        
                        UserWatchlistView(
                            watchlistItems: socialViewModel.fetchUserWatchlist(user.id),
                            socialViewModel: $socialViewModel
                        )
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(minHeight: 300)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct UserTributesView: View {
    let tributes: [Tribute]
    @Binding var socialViewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if tributes.isEmpty {
                    EmptyStateView(
                        icon: "heart.fill",
                        title: "No Tributes",
                        message: "This user hasn't created any tributes yet"
                    )
                } else {
                    ForEach(tributes, id: \.id) { tribute in
                        TributeCardView(
                            tribute: tribute,
                            viewModel: socialViewModel
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct UserDiscussionsView: View {
    let discussions: [Discussion]
    @Binding var socialViewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if discussions.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No Discussions",
                        message: "This user hasn't started any discussions yet"
                    )
                } else {
                    ForEach(discussions, id: \.id) { discussion in
                        DiscussionCardView(
                            discussion: discussion,
                            viewModel: $socialViewModel
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct UserWatchlistView: View {
    let watchlistItems: [WatchlistItem]
    @Binding var socialViewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if watchlistItems.isEmpty {
                    EmptyStateView(
                        icon: "heart.fill",
                        title: "No Watchlist Items",
                        message: "This user hasn't added any items to their Watchlist yet"
                    )
                } else {
                    ForEach(watchlistItems, id: \.id) { item in
                        WatchlistItemCardView(
                            item: item,
                            socialViewModel: $socialViewModel
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct WatchlistItemCardView: View {
    let item: WatchlistItem
    @Binding var socialViewModel: SocialViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Icon
            Image(systemName: item.priority.icon)
                .font(.title2)
                .foregroundColor(Color(item.priority.color))
                .frame(width: 40, height: 40)
                .background(Color(item.priority.color).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.celebrityName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(item.priority.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(item.priority.color))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(item.priority.color).opacity(0.1))
                        .cornerRadius(4)
                    
                    Text("Added \(item.addedDate, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 
