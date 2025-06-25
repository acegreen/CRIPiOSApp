//
//  CloudBackupService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import CloudKit

@Observable
class CloudBackupService {
    static let shared = CloudBackupService()
    
    private let container = CKContainer.default()
    private let database = CKContainer.default().privateCloudDatabase
    
    var isBackingUp = false
    var isRestoring = false
    var backupProgress: Double = 0.0
    var backupStatus: String = ""
    var lastBackupDate: Date?
    var isCloudAvailable = false
    
    private init() {
        checkCloudAvailability()
        loadLastBackupDate()
    }
    
    // MARK: - Cloud Availability
    
    func checkCloudAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isCloudAvailable = status == .available
                if let error = error {
                    print("❌ Cloud availability check failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Backup Operations
    
    func backupUserData(userProfile: UserProfile, userInterests: UserInterests, watchlist: [WatchlistItem], tributes: [Tribute]) async -> Bool {
        guard isCloudAvailable else {
            backupStatus = "iCloud not available"
            return false
        }
        
        isBackingUp = true
        backupProgress = 0.0
        backupStatus = "Preparing backup..."
        
        defer {
            isBackingUp = false
            backupProgress = 0.0
            backupStatus = ""
        }
        
        do {
            // Create backup record
            let backupRecord = CKRecord(recordType: "UserBackup")
            backupRecord["userId"] = userProfile.id.uuidString
            backupRecord["username"] = userProfile.username
            backupRecord["backupDate"] = Date()
            backupRecord["version"] = "1.0"
            
            backupProgress = 0.2
            backupStatus = "Backing up user profile..."
            
            // Backup user profile
            let profileData = try await backupUserProfile(userProfile)
            backupRecord["profileData"] = profileData
            
            backupProgress = 0.4
            backupStatus = "Backing up user interests..."
            
            // Backup user interests
            let interestsData = try JSONEncoder().encode(userInterests)
            backupRecord["interestsData"] = interestsData
            
            backupProgress = 0.6
            backupStatus = "Backing up watchlist..."
            
            // Backup watchlist
            let watchlistData = try await backupWatchlist(watchlist)
            backupRecord["watchlistData"] = watchlistData
            
            backupProgress = 0.8
            backupStatus = "Backing up tributes..."
            
            // Backup tributes
            let tributesData = try await backupTributes(tributes)
            backupRecord["tributesData"] = tributesData
            
            backupProgress = 0.9
            backupStatus = "Saving to iCloud..."
            
            // Save to CloudKit
            try await database.save(backupRecord)
            
            backupProgress = 1.0
            backupStatus = "Backup completed"
            
            // Update last backup date
            lastBackupDate = Date()
            saveLastBackupDate()
            
            print("✅ User data backed up successfully")
            return true
            
        } catch {
            backupStatus = "Backup failed: \(error.localizedDescription)"
            print("❌ Backup failed: \(error)")
            return false
        }
    }
    
    func restoreUserData(userId: String) async -> (UserProfile?, UserInterests?, [WatchlistItem], [Tribute])? {
        guard isCloudAvailable else {
            backupStatus = "iCloud not available"
            return nil
        }
        
        isRestoring = true
        backupProgress = 0.0
        backupStatus = "Searching for backup..."
        
        defer {
            isRestoring = false
            backupProgress = 0.0
            backupStatus = ""
        }
        
        do {
            // Query for user's backup
            let predicate = NSPredicate(format: "userId == %@", userId)
            let query = CKQuery(recordType: "UserBackup", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "backupDate", ascending: false)]
            
            backupProgress = 0.3
            backupStatus = "Downloading backup..."
            
            let result = try await database.records(matching: query)
            
            // Handle the tuple structure: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
            guard let firstMatch = result.matchResults.first else {
                backupStatus = "No backup found"
                return nil
            }
            
            // Handle the Result for the first record
            switch firstMatch.1 {
            case .success(let record):
                backupProgress = 0.5
                backupStatus = "Restoring user profile..."
                
                // Restore user profile
                let userProfile = try await restoreUserProfile(from: record["profileData"] as? Data)
                
                backupProgress = 0.6
                backupStatus = "Restoring user interests..."
                
                // Restore user interests
                let userInterests = try JSONDecoder().decode(UserInterests.self, from: record["interestsData"] as? Data ?? Data())
                
                backupProgress = 0.7
                backupStatus = "Restoring watchlist..."
                
                // Restore watchlist
                let watchlist = try await restoreWatchlist(from: record["watchlistData"] as? Data)
                
                backupProgress = 0.8
                backupStatus = "Restoring tributes..."
                
                // Restore tributes
                let tributes = try await restoreTributes(from: record["tributesData"] as? Data)
                
                backupProgress = 1.0
                backupStatus = "Restore completed"
                
                print("✅ User data restored successfully")
                return (userProfile, userInterests, watchlist, tributes)
                
            case .failure(let error):
                backupStatus = "Restore failed: \(error.localizedDescription)"
                print("❌ Restore failed: \(error)")
                return nil
            }
            
        } catch {
            backupStatus = "Restore failed: \(error.localizedDescription)"
            print("❌ Restore failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Data Serialization
    
    private func backupUserProfile(_ profile: UserProfile) async throws -> Data {
        let profileDict: [String: Any] = [
            "id": profile.id.uuidString,
            "username": profile.username,
            "displayName": profile.displayName,
            "bio": profile.bio ?? "",
            "avatarURL": profile.avatarURL ?? "",
            "joinDate": ISO8601DateFormatter().string(from: profile.joinDate),
            "favoriteCelebrities": profile.favoriteCelebrities,
            "interests": profile.interests,
            "isVerified": profile.isVerified,
            "followerCount": profile.followerCount,
            "followingCount": profile.followingCount,
            "tributeCount": profile.tributeCount,
            "discussionCount": profile.discussionCount,
            "lastActive": ISO8601DateFormatter().string(from: profile.lastActive)
        ]
        
        return try JSONSerialization.data(withJSONObject: profileDict)
    }
    
    private func backupWatchlist(_ watchlist: [WatchlistItem]) async throws -> Data {
        let watchlistData = watchlist.map { item in
            [
                "id": item.id.uuidString,
                "userId": item.userId.uuidString,
                "celebrityName": item.celebrityName,
                "notes": item.notes ?? "",
                "priority": item.priority.rawValue,
                "isPublic": item.isPublic,
                "addedDate": ISO8601DateFormatter().string(from: item.addedDate)
            ]
        }
        
        return try JSONSerialization.data(withJSONObject: watchlistData)
    }
    
    private func backupTributes(_ tributes: [Tribute]) async throws -> Data {
        let tributesData = tributes.map { tribute in
            [
                "id": tribute.id.uuidString,
                "authorId": tribute.authorId.uuidString,
                "celebrityName": tribute.celebrityName,
                "title": tribute.title,
                "content": tribute.content,
                "imageURLs": tribute.imageURLs,
                "tags": tribute.tags,
                "likeCount": tribute.likeCount,
                "commentCount": tribute.commentCount,
                "createdAt": ISO8601DateFormatter().string(from: tribute.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: tribute.updatedAt),
                "isEdited": tribute.isEdited
            ]
        }
        
        return try JSONSerialization.data(withJSONObject: tributesData)
    }
    
    // MARK: - Data Deserialization
    
    private func restoreUserProfile(from data: Data?) throws -> UserProfile? {
        guard let data = data else { return nil }
        
        let profileDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let profileDict = profileDict else { return nil }
        
        let profile = UserProfile(
            username: profileDict["username"] as? String ?? "",
            displayName: profileDict["displayName"] as? String ?? "",
            bio: profileDict["bio"] as? String,
            avatarURL: profileDict["avatarURL"] as? String,
            interests: profileDict["interests"] as? [String] ?? []
        )
        
        // Restore additional properties
        profile.favoriteCelebrities = profileDict["favoriteCelebrities"] as? [String] ?? []
        profile.isVerified = profileDict["isVerified"] as? Bool ?? false
        profile.followerCount = profileDict["followerCount"] as? Int ?? 0
        profile.followingCount = profileDict["followingCount"] as? Int ?? 0
        profile.tributeCount = profileDict["tributeCount"] as? Int ?? 0
        profile.discussionCount = profileDict["discussionCount"] as? Int ?? 0
        
        return profile
    }
    
    private func restoreWatchlist(from data: Data?) throws -> [WatchlistItem] {
        guard let data = data else { return [] }
        
        let watchlistArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        
        return watchlistArray.compactMap { itemDict in
            guard let userIdString = itemDict["userId"] as? String,
                  let userId = UUID(uuidString: userIdString),
                  let celebrityName = itemDict["celebrityName"] as? String else { return nil }
            
            let item = WatchlistItem(
                userId: userId,
                celebrityName: celebrityName,
                notes: itemDict["notes"] as? String,
                priority: WatchlistPriority(rawValue: itemDict["priority"] as? String ?? "medium") ?? .medium,
                isPublic: itemDict["isPublic"] as? Bool ?? true
            )
            
            return item
        }
    }
    
    private func restoreTributes(from data: Data?) throws -> [Tribute] {
        guard let data = data else { return [] }
        
        let tributesArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        
        return tributesArray.compactMap { tributeDict in
            guard let authorIdString = tributeDict["authorId"] as? String,
                  let authorId = UUID(uuidString: authorIdString),
                  let celebrityName = tributeDict["celebrityName"] as? String,
                  let title = tributeDict["title"] as? String,
                  let content = tributeDict["content"] as? String else { return nil }
            
            let tribute = Tribute(
                authorId: authorId,
                celebrityName: celebrityName,
                title: title,
                content: content,
                imageURLs: tributeDict["imageURLs"] as? [String] ?? [],
                tags: tributeDict["tags"] as? [String] ?? []
            )
            
            return tribute
        }
    }
    
    // MARK: - Backup Management
    
    func getBackupHistory(userId: String) async -> [Date] {
        guard isCloudAvailable else { return [] }
        
        do {
            let predicate = NSPredicate(format: "userId == %@", userId)
            let query = CKQuery(recordType: "UserBackup", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "backupDate", ascending: false)]
            
            let result = try await database.records(matching: query)
            
            // Handle the tuple structure and extract successful records
            return result.matchResults.compactMap { matchResult in
                switch matchResult.1 {
                case .success(let record):
                    return record["backupDate"] as? Date
                case .failure(let error):
                    print("❌ Failed to get record: \(error)")
                    return nil
                }
            }
        } catch {
            print("❌ Failed to get backup history: \(error)")
            return []
        }
    }
    
    func deleteBackup(recordID: CKRecord.ID) async -> Bool {
        guard isCloudAvailable else { return false }
        
        do {
            try await database.deleteRecord(withID: recordID)
            print("✅ Backup deleted successfully")
            return true
        } catch {
            print("❌ Failed to delete backup: \(error)")
            return false
        }
    }
    
    // MARK: - Local Storage
    
    private func saveLastBackupDate() {
        UserDefaults.standard.set(lastBackupDate, forKey: "lastBackupDate")
    }
    
    private func loadLastBackupDate() {
        lastBackupDate = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date
    }
    
    // MARK: - Auto Backup
    
    func scheduleAutoBackup() {
        // Schedule automatic backup every 24 hours
        Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
            Task {
                // This would be called when auto backup is triggered
                print("🔄 Auto backup triggered")
            }
        }
    }
} 
