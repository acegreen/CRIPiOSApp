//
//  SocialViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class SocialViewModel {
    private var modelContext: ModelContext?
    var currentUser: UserProfile?
    var isLoading = false
    var errorMessage: String?
    
    // Social feed data
    var tributes: [Tribute] = []
    var discussions: [Discussion] = []
    var comments: [Comment] = []
    var likes: [Like] = []
    var follows: [Follow] = []
    var watchlistItems: [WatchlistItem] = []
    var notifications: [AppNotification] = []
    
    // User management
    var suggestedUsers: [UserProfile] = []
    var followingUsers: [UserProfile] = []
    var followers: [UserProfile] = []
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        setupInitialData()
    }
    
    // MARK: - SwiftData Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        setupInitialData()
    }
    
    private func setupInitialData() {
        guard let modelContext = modelContext else { return }
        
        // Check if we have any social data
        let userDescriptor = FetchDescriptor<UserProfile>()
        let tributeDescriptor = FetchDescriptor<Tribute>()
        let discussionDescriptor = FetchDescriptor<Discussion>()
        
        do {
            let existingUsers = try modelContext.fetch(userDescriptor)
            _ = try modelContext.fetch(tributeDescriptor)
            _ = try modelContext.fetch(discussionDescriptor)
            
            if existingUsers.isEmpty {
                loadSampleSocialData()
            } else {
                refreshSocialData()
            }
        } catch {
            print("❌ Error fetching social data: \(error)")
            // If there's an error, it might be due to schema changes
            // Clear and reload data to fix migration issues
            print("🔄 Clearing social data due to schema migration issues...")
            clearSocialData()
            loadSampleSocialData()
        }
    }
    
    private func clearSocialData() {
        guard let modelContext = modelContext else { return }
        
        print("🗑️ Clearing all social data from database...")
        
        // Clear all social data
        do {
            // Clear UserProfiles
            let userDescriptor = FetchDescriptor<UserProfile>()
            let users = try modelContext.fetch(userDescriptor)
            for user in users { modelContext.delete(user) }
            
            // Clear Tributes
            let tributeDescriptor = FetchDescriptor<Tribute>()
            let tributes = try modelContext.fetch(tributeDescriptor)
            for tribute in tributes { modelContext.delete(tribute) }
            
            // Clear Discussions
            let discussionDescriptor = FetchDescriptor<Discussion>()
            let discussions = try modelContext.fetch(discussionDescriptor)
            for discussion in discussions { modelContext.delete(discussion) }
            
            // Clear Comments
            let commentDescriptor = FetchDescriptor<Comment>()
            let comments = try modelContext.fetch(commentDescriptor)
            for comment in comments { modelContext.delete(comment) }
            
            // Clear Likes
            let likeDescriptor = FetchDescriptor<Like>()
            let likes = try modelContext.fetch(likeDescriptor)
            for like in likes { modelContext.delete(like) }
            
            // Clear Follows
            let followDescriptor = FetchDescriptor<Follow>()
            let follows = try modelContext.fetch(followDescriptor)
            for follow in follows { modelContext.delete(follow) }
            
            // Clear WatchlistItems
            let watchlistDescriptor = FetchDescriptor<WatchlistItem>()
            let watchlistItems = try modelContext.fetch(watchlistDescriptor)
            for item in watchlistItems { modelContext.delete(item) }
            
            // Clear Notifications
            let notificationDescriptor = FetchDescriptor<AppNotification>()
            let notifications = try modelContext.fetch(notificationDescriptor)
            for notification in notifications { modelContext.delete(notification) }
            
        } catch {
            print("❌ Error clearing social data: \(error)")
        }
        
        do {
            try modelContext.save()
            print("✅ Cleared all social data from database")
        } catch {
            print("❌ Error saving after clearing: \(error)")
        }
    }
    
    private func loadSampleSocialData() {
        guard let modelContext = modelContext else { return }
        
        // Load sample users
        for profile in UserProfile.sampleProfiles {
            modelContext.insert(profile)
        }
        
        // Load sample tributes
        for tribute in Tribute.sampleTributes {
            modelContext.insert(tribute)
        }
        
        // Load sample discussions
        for discussion in Discussion.sampleDiscussions {
            modelContext.insert(discussion)
        }
        
        // Load sample watchlist items
        for watchlistItem in WatchlistItem.sampleWatchlistItems {
            modelContext.insert(watchlistItem)
        }
        
        // Load sample notifications
        let sampleNotifications = [
            AppNotification(
                userId: UserProfile.sampleProfiles[0].id,
                type: .deathAlert,
                title: "Death Alert",
                message: "Sophia Leone has passed away. Our thoughts are with her family and friends."
            ),
            AppNotification(
                userId: UserProfile.sampleProfiles[0].id,
                type: .newTribute,
                title: "New Tribute",
                message: "Sarah Johnson created a tribute for Robin Williams"
            ),
            AppNotification(
                userId: UserProfile.sampleProfiles[0].id,
                type: .newFollower,
                title: "New Follower",
                message: "Mike Chen started following you"
            ),
            AppNotification(
                userId: UserProfile.sampleProfiles[1].id,
                type: .likeReceived,
                title: "Like Received",
                message: "Emma Davis liked your tribute to David Bowie"
            )
        ]
        
        for notification in sampleNotifications {
            modelContext.insert(notification)
        }
        
        do {
            try modelContext.save()
            refreshSocialData()
        } catch {
            print("❌ Error saving sample social data: \(error)")
        }
    }
    
    // MARK: - User Management
    
    func createUserProfile(username: String, displayName: String, bio: String?, interests: [String]) {
        guard let modelContext = modelContext else { return }
        
        let newProfile = UserProfile(
            username: username,
            displayName: displayName,
            bio: bio,
            interests: interests
        )
        
        modelContext.insert(newProfile)
        saveContext()
        
        currentUser = newProfile
    }
    
    func loginUser(username: String) {
        let users = fetchUserProfiles()
        if let user = users.first(where: { $0.username == username }) {
            currentUser = user
            user.lastActive = Date()
            saveContext()
        } else {
            errorMessage = "User not found"
        }
    }
    
    func logoutUser() {
        currentUser = nil
    }
    
    // MARK: - Tribute Management
    
    func createTribute(celebrityName: String, title: String, content: String, tags: [String] = []) {
        guard let modelContext = modelContext,
              let currentUser = currentUser else { return }
        
        let tribute = Tribute(
            authorId: currentUser.id,
            celebrityName: celebrityName,
            title: title,
            content: content,
            tags: tags
        )
        
        modelContext.insert(tribute)
        currentUser.tributeCount += 1
        saveContext()
        
        refreshSocialData()
    }
    
    func likeTribute(_ tribute: Tribute) {
        guard let currentUser = currentUser else { return }
        
        let existingLike = fetchLike(userId: currentUser.id, targetId: tribute.id, targetType: .tribute)
        
        if existingLike != nil {
            // Unlike
            deleteLike(existingLike!)
            tribute.likeCount = max(0, tribute.likeCount - 1)
        } else {
            // Like
            let like = Like(userId: currentUser.id, targetId: tribute.id, targetType: .tribute)
            modelContext?.insert(like)
            tribute.likeCount += 1
            
            // Create notification for the tribute author (if not liking their own tribute)
            if tribute.authorId != currentUser.id {
                createNotification(
                    type: .likeReceived,
                    title: "Like Received",
                    message: "\(currentUser.displayName) liked your tribute to \(tribute.celebrityName)",
                    relatedId: tribute.id,
                    relatedType: "tribute"
                )
            }
        }
        
        saveContext()
        refreshSocialData()
    }
    
    // MARK: - Discussion Management
    
    func createDiscussion(title: String, content: String, category: DiscussionCategory, tags: [String] = []) {
        guard let modelContext = modelContext,
              let currentUser = currentUser else { return }
        
        let discussion = Discussion(
            authorId: currentUser.id,
            title: title,
            content: content,
            category: category,
            tags: tags
        )
        
        modelContext.insert(discussion)
        currentUser.discussionCount += 1
        saveContext()
        
        refreshSocialData()
    }
    
    func likeDiscussion(_ discussion: Discussion) {
        guard let currentUser = currentUser else { return }
        
        let existingLike = fetchLike(userId: currentUser.id, targetId: discussion.id, targetType: .discussion)
        
        if existingLike != nil {
            // Unlike
            deleteLike(existingLike!)
            discussion.likeCount = max(0, discussion.likeCount - 1)
        } else {
            // Like
            let like = Like(userId: currentUser.id, targetId: discussion.id, targetType: .discussion)
            modelContext?.insert(like)
            discussion.likeCount += 1
            
            // Create notification for the discussion author (if not liking their own discussion)
            if discussion.authorId != currentUser.id {
                createNotification(
                    type: .likeReceived,
                    title: "Like Received",
                    message: "\(currentUser.displayName) liked your discussion: \(discussion.title)",
                    relatedId: discussion.id,
                    relatedType: "discussion"
                )
            }
        }
        
        saveContext()
        refreshSocialData()
    }
    
    // MARK: - Follow System
    
    func followUser(_ userToFollow: UserProfile) {
        guard let modelContext = modelContext,
              let currentUser = currentUser,
              currentUser.id != userToFollow.id else { return }
        
        let existingFollow = fetchFollow(followerId: currentUser.id, followingId: userToFollow.id)
        
        if existingFollow != nil {
            // Unfollow
            deleteFollow(existingFollow!)
            currentUser.followingCount = max(0, currentUser.followingCount - 1)
            userToFollow.followerCount = max(0, userToFollow.followerCount - 1)
        } else {
            // Follow
            let follow = Follow(followerId: currentUser.id, followingId: userToFollow.id)
            modelContext.insert(follow)
            currentUser.followingCount += 1
            userToFollow.followerCount += 1
        }
        
        saveContext()
        refreshSocialData()
    }
    
    func isFollowing(_ user: UserProfile) -> Bool {
        guard let currentUser = currentUser else { return false }
        return fetchFollow(followerId: currentUser.id, followingId: user.id) != nil
    }
    
    func hasLikedTribute(_ tribute: Tribute) -> Bool {
        guard let currentUser = currentUser else { return false }
        return fetchLike(userId: currentUser.id, targetId: tribute.id, targetType: .tribute) != nil
    }
    
    func hasLikedDiscussion(_ discussion: Discussion) -> Bool {
        guard let currentUser = currentUser else { return false }
        return fetchLike(userId: currentUser.id, targetId: discussion.id, targetType: .discussion) != nil
    }
    
    // MARK: - Watchlist Management
    
    func addToWatchlist(celebrityName: String, notes: String? = nil, priority: WatchlistPriority = .medium, isPublic: Bool = true) {
        guard let modelContext = modelContext,
              let currentUser = currentUser else { return }
        
        // Check if already in Watchlist
        let existingItem = fetchWatchlistItem(userId: currentUser.id, celebrityName: celebrityName)
        if existingItem != nil {
            return
        }
        
        let WatchlistItem = WatchlistItem(
            userId: currentUser.id,
            celebrityName: celebrityName,
            notes: notes,
            priority: priority,
            isPublic: isPublic
        )
        
        modelContext.insert(WatchlistItem)
        saveContext()
        
        refreshSocialData()
    }
    
    func removeFromWatchlist(celebrityName: String) {
        guard let modelContext = modelContext,
              let currentUser = currentUser else { return }
        
        let existingItem = fetchWatchlistItem(userId: currentUser.id, celebrityName: celebrityName)
        if let item = existingItem {
            modelContext.delete(item)
            saveContext()
            refreshSocialData()
        }
    }
    
    func updateWatchlistItem(_ item: WatchlistItem, notes: String?, priority: WatchlistPriority, isPublic: Bool) {
        item.notes = notes
        item.priority = priority
        item.isPublic = isPublic
        saveContext()
        refreshSocialData()
    }
    
    func isInWatchlist(celebrityName: String) -> Bool {
        guard let currentUser = currentUser else { return false }
        return fetchWatchlistItem(userId: currentUser.id, celebrityName: celebrityName) != nil
    }
    
    func getWatchlistItem(celebrityName: String) -> WatchlistItem? {
        guard let currentUser = currentUser else { return nil }
        return fetchWatchlistItem(userId: currentUser.id, celebrityName: celebrityName)
    }
    
    // MARK: - Fetch Methods
    
    func fetchUserProfiles() -> [UserProfile] {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching user profiles: \(error)")
            return []
        }
    }
    
    func fetchTributes() -> [Tribute] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<Tribute>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching tributes: \(error)")
            return []
        }
    }
    
    func fetchDiscussions() -> [Discussion] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<Discussion>()
        descriptor.sortBy = [SortDescriptor(\.lastActivityAt, order: .reverse)]
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching discussions: \(error)")
            return []
        }
    }
    
    func fetchTributesForCelebrity(_ celebrityName: String) -> [Tribute] {
        return fetchTributes().filter { $0.celebrityName == celebrityName }
    }
    
    func fetchUserTributes(_ userId: UUID) -> [Tribute] {
        return fetchTributes().filter { $0.authorId == userId }
    }
    
    func fetchUserDiscussions(_ userId: UUID) -> [Discussion] {
        return fetchDiscussions().filter { $0.authorId == userId }
    }
    
    func fetchFollow(followerId: UUID, followingId: UUID) -> Follow? {
        guard let modelContext = modelContext else { return nil }
        
        var descriptor = FetchDescriptor<Follow>()
        descriptor.predicate = #Predicate<Follow> { follow in
            follow.followerId == followerId && follow.followingId == followingId
        }
        
        do {
            let follows = try modelContext.fetch(descriptor)
            return follows.first
        } catch {
            print("❌ Error fetching follow: \(error)")
            return nil
        }
    }
    
    func fetchLike(userId: UUID, targetId: UUID, targetType: LikeTargetType) -> Like? {
        guard let modelContext = modelContext else { return nil }
        
        var descriptor = FetchDescriptor<Like>()
        descriptor.predicate = #Predicate<Like> { like in
            like.userId == userId && like.targetId == targetId && like.targetType == targetType
        }
        
        do {
            let likes = try modelContext.fetch(descriptor)
            return likes.first
        } catch {
            print("❌ Error fetching like: \(error)")
            return nil
        }
    }
    
    func fetchFollowingUsers() -> [UserProfile] {
        guard let currentUser = currentUser else { return [] }
        
        let follows = fetchFollows(followerId: currentUser.id)
        let followingIds = follows.map { $0.followingId }
        
        return fetchUserProfiles().filter { followingIds.contains($0.id) }
    }
    
    func fetchFollowers() -> [UserProfile] {
        guard let currentUser = currentUser else { return [] }
        
        let follows = fetchFollows(followingId: currentUser.id)
        let followerIds = follows.map { $0.followerId }
        
        return fetchUserProfiles().filter { followerIds.contains($0.id) }
    }
    
    private func fetchFollows(followerId: UUID? = nil, followingId: UUID? = nil) -> [Follow] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<Follow>()
        if let followerId = followerId {
            descriptor.predicate = #Predicate<Follow> { follow in
                follow.followerId == followerId
            }
        } else if let followingId = followingId {
            descriptor.predicate = #Predicate<Follow> { follow in
                follow.followingId == followingId
            }
        }
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching follows: \(error)")
            return []
        }
    }
    
    func fetchWatchlistItem(userId: UUID, celebrityName: String) -> WatchlistItem? {
        guard let modelContext = modelContext else { return nil }
        
        var descriptor = FetchDescriptor<WatchlistItem>()
        descriptor.predicate = #Predicate<WatchlistItem> { item in
            item.userId == userId && item.celebrityName == celebrityName
        }
        
        do {
            let items = try modelContext.fetch(descriptor)
            return items.first
        } catch {
            print("❌ Error fetching Watchlist item: \(error)")
            return nil
        }
    }
    
    func fetchWatchlistItems() -> [WatchlistItem] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<WatchlistItem>()
        descriptor.sortBy = [SortDescriptor(\.addedDate, order: .reverse)]
        do {
            let items = try modelContext.fetch(descriptor)
            // Manual sort by priority (critical, high, medium, low)
            return items.sorted { item1, item2 in
                let priorityOrder: [WatchlistPriority] = [.critical, .high, .medium, .low]
                let index1 = priorityOrder.firstIndex(of: item1.priority) ?? 0
                let index2 = priorityOrder.firstIndex(of: item2.priority) ?? 0
                return index1 < index2
            }
        } catch {
            print("❌ Error fetching Watchlist items: \(error)")
            return []
        }
    }
    
    func fetchUserWatchlist(_ userId: UUID) -> [WatchlistItem] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<WatchlistItem>()
        descriptor.predicate = #Predicate<WatchlistItem> { item in
            item.userId == userId && item.isPublic
        }
        descriptor.sortBy = [SortDescriptor(\.addedDate, order: .reverse)]
        
        do {
            let items = try modelContext.fetch(descriptor)
            // Manual sort by priority (critical, high, medium, low)
            return items.sorted { item1, item2 in
                let priorityOrder: [WatchlistPriority] = [.critical, .high, .medium, .low]
                let index1 = priorityOrder.firstIndex(of: item1.priority) ?? 0
                let index2 = priorityOrder.firstIndex(of: item2.priority) ?? 0
                return index1 < index2
            }
        } catch {
            print("❌ Error fetching user Watchlist: \(error)")
            return []
        }
    }
    
    func fetchPublicWatchlists() -> [WatchlistItem] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<WatchlistItem>()
        descriptor.predicate = #Predicate<WatchlistItem> { item in
            item.isPublic
        }
        descriptor.sortBy = [SortDescriptor(\.addedDate, order: .reverse)]
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching public Watchlists: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Methods
    
    private func deleteLike(_ like: Like) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(like)
    }
    
    private func deleteFollow(_ follow: Follow) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(follow)
    }
    
    // MARK: - Data Refresh
    
    func refreshSocialData() {
        tributes = fetchTributes()
        discussions = fetchDiscussions()
        watchlistItems = fetchWatchlistItems()
        notifications = getUserNotifications()
        suggestedUsers = fetchUserProfiles().filter { $0.id != currentUser?.id }
        followingUsers = fetchFollowingUsers()
        followers = fetchFollowers()
    }
    
    // MARK: - Utility Methods
    
    func getUserProfile(_ userId: UUID) -> UserProfile? {
        return fetchUserProfiles().first { $0.id == userId }
    }
    
    func getAuthorName(_ authorId: UUID) -> String {
        return getUserProfile(authorId)?.displayName ?? "Unknown User"
    }
    
    func getAuthorUsername(_ authorId: UUID) -> String {
        return getUserProfile(authorId)?.username ?? "unknown"
    }
    
    // MARK: - Notification Management
    
    func createNotification(type: NotificationType, title: String, message: String, relatedId: UUID? = nil, relatedType: String? = nil) {
        guard let modelContext = modelContext,
              let currentUser = currentUser else { return }
        
        let notification = AppNotification(
            userId: currentUser.id,
            type: type,
            title: title,
            message: message,
            relatedId: relatedId,
            relatedType: relatedType
        )
        
        modelContext.insert(notification)
        saveContext()
        refreshSocialData()
    }
    
    func markNotificationAsRead(_ notification: AppNotification) {
        notification.isRead = true
        saveContext()
        refreshSocialData()
    }
    
    func markAllNotificationsAsRead() {
        guard let currentUser = currentUser else { return }
        
        let userNotifications = fetchNotifications(userId: currentUser.id)
        for notification in userNotifications {
            notification.isRead = true
        }
        saveContext()
        refreshSocialData()
    }
    
    func deleteNotification(_ notification: AppNotification) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(notification)
        saveContext()
        refreshSocialData()
    }
    
    func fetchNotifications(userId: UUID? = nil) -> [AppNotification] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<AppNotification>()
        if let userId = userId {
            descriptor.predicate = #Predicate<AppNotification> { notification in
                notification.userId == userId
            }
        }
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching notifications: \(error)")
            return []
        }
    }
    
    func getUnreadNotificationCount() -> Int {
        guard let currentUser = currentUser else { return 0 }
        return fetchNotifications(userId: currentUser.id).filter { !$0.isRead }.count
    }
    
    func getUserNotifications() -> [AppNotification] {
        guard let currentUser = currentUser else { return [] }
        return fetchNotifications(userId: currentUser.id)
    }
    
    // MARK: - Timeline Support
    
    func fetchRecentTributes(limit: Int = 20) -> [Tribute] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<Tribute>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching recent tributes: \(error)")
            return []
        }
    }
    
    func fetchRecentDiscussions(limit: Int = 20) -> [Discussion] {
        guard let modelContext = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<Discussion>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching recent discussions: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
} 
