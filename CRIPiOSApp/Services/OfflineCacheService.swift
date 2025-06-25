//
//  OfflineCacheService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import Network

@Observable
class OfflineCacheService {
    static let shared = OfflineCacheService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isOnline = true
    var cacheSize: Int64 = 0
    var lastCacheUpdate: Date?
    var isCaching = false
    var cacheProgress: Double = 0.0
    var cacheStatus: String = ""
    
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    private init() {
        // Set up cache directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("OfflineCache")
        
        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Start network monitoring
        startNetworkMonitoring()
        
        // Load cache info
        loadCacheInfo()
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if self?.isOnline == true {
                    self?.onNetworkRestored()
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func onNetworkRestored() {
        // When network is restored, we could trigger a cache update
        print("🌐 Network restored - cache is available")
    }
    
    // MARK: - Cache Management
    
    func cacheCelebrityData(_ celebrities: [Celebrity]) async {
        guard isOnline else {
            cacheStatus = "Cannot cache while offline"
            return
        }
        
        isCaching = true
        cacheProgress = 0.0
        cacheStatus = "Preparing cache..."
        
        defer {
            isCaching = false
            cacheProgress = 0.0
            cacheStatus = ""
        }
        
        do {
            // Clear old cache
            cacheProgress = 0.1
            cacheStatus = "Clearing old cache..."
            try clearCache()
            
            // Cache celebrity data
            cacheProgress = 0.2
            cacheStatus = "Caching celebrity data..."
            try await cacheCelebrities(celebrities)
            
            // Cache images
            cacheProgress = 0.4
            cacheStatus = "Caching celebrity images..."
            try await cacheCelebrityImages(celebrities)
            
            // Cache additional data
            cacheProgress = 0.7
            cacheStatus = "Caching additional data..."
            try await cacheAdditionalData()
            
            // Update cache info
            cacheProgress = 0.9
            cacheStatus = "Finalizing cache..."
            updateCacheInfo()
            
            cacheProgress = 1.0
            cacheStatus = "Cache completed"
            
            lastCacheUpdate = Date()
            saveCacheInfo()
            
            print("✅ Offline cache updated successfully")
            
        } catch {
            cacheStatus = "Cache failed: \(error.localizedDescription)"
            print("❌ Cache failed: \(error)")
        }
    }
    
    func loadCachedData() -> [Celebrity]? {
        // For now, return nil since we're not implementing full caching
        // In a real implementation, you would load from SwiftData or a different storage mechanism
        return nil
    }
    
    func getCachedImage(for celebrity: Celebrity) -> UIImage? {
        let imageFile = cacheDirectory.appendingPathComponent("\(celebrity.id.uuidString).jpg")
        
        guard let imageData = try? Data(contentsOf: imageFile) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    // MARK: - Cache Operations
    
    private func cacheCelebrities(_ celebrities: [Celebrity]) async throws {
        // Store celebrity data in a simple format that can be easily read
        let cacheFile = cacheDirectory.appendingPathComponent("celebrities.txt")
        var celebrityData = ""
        
        for celebrity in celebrities {
            celebrityData += "ID: \(celebrity.id)\n"
            celebrityData += "Name: \(celebrity.name)\n"
            celebrityData += "Occupation: \(celebrity.occupation)\n"
            celebrityData += "Age: \(celebrity.age)\n"
            celebrityData += "ImageURL: \(celebrity.imageURL)\n"
            celebrityData += "IsDeceased: \(celebrity.isDeceased)\n"
            celebrityData += "DeathDate: \(celebrity.deathDate ?? "N/A")\n"
            celebrityData += "BirthDate: \(celebrity.birthDate ?? "N/A")\n"
            celebrityData += "CauseOfDeath: \(celebrity.causeOfDeath ?? "N/A")\n"
            celebrityData += "Nationality: \(celebrity.nationality ?? "N/A")\n"
            celebrityData += "NetWorth: \(celebrity.netWorth ?? "N/A")\n"
            celebrityData += "Interests: \(celebrity.interests.joined(separator: ", "))\n"
            celebrityData += "IsFeatured: \(celebrity.isFeatured)\n"
            celebrityData += "LastUpdated: \(celebrity.lastUpdated)\n"
            celebrityData += "---\n"
        }
        
        try celebrityData.write(to: cacheFile, atomically: true, encoding: .utf8)
    }
    
    private func cacheCelebrityImages(_ celebrities: [Celebrity]) async throws {
        let imageCacheGroup = DispatchGroup()
        var imageCacheErrors: [Error] = []
        
        for (index, celebrity) in celebrities.enumerated() {
            imageCacheGroup.enter()
            
            Task {
                do {
                    if let imageURL = URL(string: celebrity.imageURL) {
                        let (data, _) = try await URLSession.shared.data(from: imageURL)
                        let imageFile = self.cacheDirectory.appendingPathComponent("\(celebrity.id.uuidString).jpg")
                        try data.write(to: imageFile)
                    }
                } catch {
                    imageCacheErrors.append(error)
                }
                
                // Update progress
                await MainActor.run {
                    self.cacheProgress = 0.4 + (0.3 * Double(index) / Double(celebrities.count))
                }
                
                imageCacheGroup.leave()
            }
        }
        
        imageCacheGroup.wait()
        
        if !imageCacheErrors.isEmpty {
            print("⚠️ Some images failed to cache: \(imageCacheErrors.count) errors")
        }
    }
    
    private func cacheAdditionalData() async throws {
        // Cache sample tributes in simple text format
        let tributes = Tribute.sampleTributes
        let tributesFile = cacheDirectory.appendingPathComponent("tributes.txt")
        var tributesData = ""
        
        for tribute in tributes {
            tributesData += "ID: \(tribute.id)\n"
            tributesData += "AuthorID: \(tribute.authorId)\n"
            tributesData += "CelebrityName: \(tribute.celebrityName)\n"
            tributesData += "Title: \(tribute.title)\n"
            tributesData += "Content: \(tribute.content)\n"
            tributesData += "ImageURLs: \(tribute.imageURLs.joined(separator: ", "))\n"
            tributesData += "Tags: \(tribute.tags.joined(separator: ", "))\n"
            tributesData += "LikeCount: \(tribute.likeCount)\n"
            tributesData += "CommentCount: \(tribute.commentCount)\n"
            tributesData += "CreatedAt: \(tribute.createdAt)\n"
            tributesData += "UpdatedAt: \(tribute.updatedAt)\n"
            tributesData += "IsEdited: \(tribute.isEdited)\n"
            tributesData += "---\n"
        }
        
        try tributesData.write(to: tributesFile, atomically: true, encoding: .utf8)
        
        // Cache sample user profiles
        let profiles = UserProfile.sampleProfiles
        let profilesFile = cacheDirectory.appendingPathComponent("profiles.txt")
        var profilesData = ""
        
        for profile in profiles {
            profilesData += "ID: \(profile.id)\n"
            profilesData += "Username: \(profile.username)\n"
            profilesData += "DisplayName: \(profile.displayName)\n"
            profilesData += "Bio: \(profile.bio ?? "N/A")\n"
            profilesData += "AvatarURL: \(profile.avatarURL ?? "N/A")\n"
            profilesData += "JoinDate: \(profile.joinDate)\n"
            profilesData += "FavoriteCelebrities: \(profile.favoriteCelebrities.joined(separator: ", "))\n"
            profilesData += "Interests: \(profile.interests.joined(separator: ", "))\n"
            profilesData += "IsVerified: \(profile.isVerified)\n"
            profilesData += "FollowerCount: \(profile.followerCount)\n"
            profilesData += "FollowingCount: \(profile.followingCount)\n"
            profilesData += "TributeCount: \(profile.tributeCount)\n"
            profilesData += "DiscussionCount: \(profile.discussionCount)\n"
            profilesData += "LastActive: \(profile.lastActive)\n"
            profilesData += "---\n"
        }
        
        try profilesData.write(to: profilesFile, atomically: true, encoding: .utf8)
        
        // Cache sample watchlist
        let watchlist = WatchlistItem.sampleWatchlistItems
        let watchlistFile = cacheDirectory.appendingPathComponent("watchlist.txt")
        var watchlistData = ""
        
        for item in watchlist {
            watchlistData += "ID: \(item.id)\n"
            watchlistData += "UserID: \(item.userId)\n"
            watchlistData += "CelebrityName: \(item.celebrityName)\n"
            watchlistData += "AddedDate: \(item.addedDate)\n"
            watchlistData += "Notes: \(item.notes ?? "N/A")\n"
            watchlistData += "Priority: \(item.priority.rawValue)\n"
            watchlistData += "IsPublic: \(item.isPublic)\n"
            watchlistData += "---\n"
        }
        
        try watchlistData.write(to: watchlistFile, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Cache Utilities
    
    private func clearCache() throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for file in contents {
            try fileManager.removeItem(at: file)
        }
        
        cacheSize = 0
    }
    
    private func updateCacheInfo() {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            
            for file in contents {
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        } catch {
            print("❌ Failed to calculate cache size: \(error)")
        }
        
        cacheSize = totalSize
    }
    
    private func loadCacheInfo() {
        lastCacheUpdate = UserDefaults.standard.object(forKey: "lastCacheUpdate") as? Date
        updateCacheInfo()
    }
    
    private func saveCacheInfo() {
        UserDefaults.standard.set(lastCacheUpdate, forKey: "lastCacheUpdate")
    }
    
    // MARK: - Cache Status
    
    func getCacheStatus() -> CacheStatus {
        guard let lastUpdate = lastCacheUpdate else {
            return .noCache
        }
        
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
        
        if daysSinceUpdate > 7 {
            return .outdated
        } else if daysSinceUpdate > 3 {
            return .stale
        } else {
            return .fresh
        }
    }
    
    func getCacheSizeString() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: cacheSize)
    }
    
    func isCacheExpired() -> Bool {
        guard let lastUpdate = lastCacheUpdate else { return true }
        
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
        return daysSinceUpdate > 7
    }
    
    // MARK: - Offline Mode
    
    func isOfflineModeAvailable() -> Bool {
        return !isOnline && getCacheStatus() != .noCache
    }
    
    func getOfflineCelebrities() -> [Celebrity] {
        return loadCachedData() ?? []
    }
    
    func getOfflineTributes() -> [Tribute] {
        // For now, return empty array since we're not implementing full caching
        // In a real implementation, you would load from SwiftData
        return []
    }
    
    func getOfflineUserProfiles() -> [UserProfile] {
        // For now, return empty array since we're not implementing full caching
        // In a real implementation, you would load from SwiftData
        return []
    }
    
    func getOfflineWatchlist() -> [WatchlistItem] {
        // For now, return empty array since we're not implementing full caching
        // In a real implementation, you would load from SwiftData
        return []
    }
    
    // MARK: - Cache Maintenance
    
    func cleanupCache() {
        guard cacheSize > maxCacheSize else { return }
        
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
            
            // Sort files by creation date (oldest first)
            let sortedFiles = contents.sorted { file1, file2 in
                let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate
                let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate
                return (date1 ?? Date.distantPast) < (date2 ?? Date.distantPast)
            }
            
            var currentSize = cacheSize
            
            // Remove oldest files until we're under the limit
            for file in sortedFiles {
                if currentSize <= maxCacheSize { break }
                
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    try fileManager.removeItem(at: file)
                    currentSize -= Int64(fileSize)
                }
            }
            
            cacheSize = currentSize
            print("🧹 Cache cleaned up - new size: \(getCacheSizeString())")
            
        } catch {
            print("❌ Failed to cleanup cache: \(error)")
        }
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Cache Status Enum

enum CacheStatus {
    case noCache
    case fresh
    case stale
    case outdated
    
    var description: String {
        switch self {
        case .noCache: return "No cache available"
        case .fresh: return "Cache is fresh"
        case .stale: return "Cache is getting old"
        case .outdated: return "Cache is outdated"
        }
    }
    
    var color: Color {
        switch self {
        case .noCache: return .red
        case .fresh: return .green
        case .stale: return .orange
        case .outdated: return .red
        }
    }
} 
