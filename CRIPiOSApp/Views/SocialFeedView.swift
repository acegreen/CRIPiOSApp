//
//  SocialFeedView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct SocialFeedView: View {
    @Binding var viewModel: SocialViewModel
    @State private var selectedTab = 0
    @State private var showingCreateTribute = false
    @State private var showingCreateDiscussion = false
    
    init(viewModel: Binding<SocialViewModel>) {
        self._viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Picker
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
                        title: "Community",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                }
                .background(Color(.systemGray6))
                
                // Content based on selected tab
                if viewModel.isLoggedIn {
                    TabView(selection: $selectedTab) {
                        TributesTabView(viewModel: $viewModel)
                            .tag(0)
                        
                        DiscussionsTabView(viewModel: $viewModel)
                            .tag(1)
                        
                        CommunityTabView(viewModel: $viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                } else {
                    // Login Prompt
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text("Sign In to Access Social Features")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Create an account or sign in to view tributes, discussions, and connect with the community.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoggedIn {
                        Menu {
                            Button(action: { showingCreateTribute = true }) {
                                Label("Create Tribute", systemImage: "heart.fill")
                            }
                            
                            Button(action: { showingCreateDiscussion = true }) {
                                Label("Start Discussion", systemImage: "bubble.left.and.bubble.right")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTribute) {
                CreateTributeView(socialViewModel: viewModel)
            }
            .sheet(isPresented: $showingCreateDiscussion) {
                CreateDiscussionView(socialViewModel: viewModel)
            }
            .refreshable {
                viewModel.refreshSocialData()
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded))
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TributesTabView: View {
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.tributes.isEmpty {
                    EmptyStateView(
                        icon: "heart.fill",
                        title: "No Tributes Yet",
                        message: "Be the first to create a tribute for a beloved celebrity"
                    )
                } else {
                    ForEach(viewModel.tributes, id: \.id) { tribute in
                        TributeCardView(
                            tribute: tribute,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct DiscussionsTabView: View {
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.discussions.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No Discussions Yet",
                        message: "Start a conversation about celebrities and their impact"
                    )
                } else {
                    ForEach(viewModel.discussions, id: \.id) { discussion in
                        DiscussionCardView(
                            discussion: discussion,
                            viewModel: $viewModel
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct CommunityTabView: View {
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Suggested Users
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested Users")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.suggestedUsers, id: \.id) { user in
                                UserCardView(
                                    user: user,
                                    viewModel: $viewModel
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Following Users
                if !viewModel.followingUsers.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Following")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.followingUsers, id: \.id) { user in
                                UserRowView(
                                    user: user,
                                    viewModel: $viewModel
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TributeCardView: View {
    let tribute: Tribute
    let viewModel: SocialViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(viewModel.getAuthorName(tribute.authorId).prefix(1)))
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.getAuthorName(tribute.authorId))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("@\(viewModel.getAuthorUsername(tribute.authorId))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(tribute.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Celebrity Name
            Text("Remembering \(tribute.celebrityName)")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            // Title
            Text(tribute.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Content
            Text(tribute.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(6)
            
            // Tags
            if !tribute.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tribute.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Actions
            HStack {
                Button(action: {
                    viewModel.likeTribute(tribute)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.hasLikedTribute(tribute) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.hasLikedTribute(tribute) ? .red : .secondary)
                        
                        Text("\(tribute.likeCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    // TODO: Add comment functionality
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)
                        
                        Text("\(tribute.commentCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                if tribute.isEdited {
                    Text("edited")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DiscussionCardView: View {
    let discussion: Discussion
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(viewModel.getAuthorName(discussion.authorId).prefix(1)))
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.getAuthorName(discussion.authorId))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("@\(viewModel.getAuthorUsername(discussion.authorId))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(discussion.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Category Badge
            HStack {
                Text(discussion.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(discussion.category.color))
                    .cornerRadius(8)
                
                if discussion.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            
            // Title
            Text(discussion.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Content
            Text(discussion.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(4)
            
            // Tags
            if !discussion.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(discussion.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Stats
            HStack {
                Button(action: {
                    viewModel.likeDiscussion(discussion)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.hasLikedDiscussion(discussion) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.hasLikedDiscussion(discussion) ? .red : .secondary)
                        
                        Text("\(discussion.likeCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    // TODO: Add comment functionality
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)
                        
                        Text("\(discussion.commentCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack(spacing: 4) {
                    Image(systemName: "eye")
                        .foregroundColor(.secondary)
                    
                    Text("\(discussion.viewCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(discussion.lastActivityAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct UserCardView: View {
    let user: UserProfile
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Button(action: {
                viewModel.followUser(user)
            }) {
                Text(viewModel.isFollowing(user) ? "Following" : "Follow")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.isFollowing(user) ? .secondary : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(viewModel.isFollowing(user) ? Color(.systemGray4) : Color.accentColor)
                    .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 120)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct UserRowView: View {
    let user: UserProfile
    @Binding var viewModel: SocialViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(user.followerCount) followers")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    viewModel.followUser(user)
                }) {
                    Text(viewModel.isFollowing(user) ? "Following" : "Follow")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.isFollowing(user) ? .secondary : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(viewModel.isFollowing(user) ? Color(.systemGray4) : Color.accentColor)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 
