//
//  Models.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models
@Model
final class Celebrity {
    @Attribute(.unique) var id: UUID
    var name: String
    var occupation: String
    var age: Int
    var imageURL: String
    var isDeceased: Bool
    var deathDate: String?
    var birthDate: String?
    var causeOfDeath: String?
    var nationality: String?
    var netWorth: String?
    @Attribute(.externalStorage) var interests: [String]
    var isFeatured: Bool
    var lastUpdated: Date
    
    init(name: String, occupation: String, age: Int, imageURL: String, isDeceased: Bool, deathDate: String?, birthDate: String?, causeOfDeath: String? = nil, nationality: String? = nil, netWorth: String? = nil, interests: [String] = [], isFeatured: Bool = false) {
        self.id = UUID()
        self.name = name
        self.occupation = occupation
        self.age = age
        self.imageURL = imageURL
        self.isDeceased = isDeceased
        self.deathDate = deathDate
        self.birthDate = birthDate
        self.causeOfDeath = causeOfDeath
        self.nationality = nationality
        self.netWorth = netWorth
        self.interests = interests
        self.isFeatured = isFeatured
        self.lastUpdated = Date()
    }
}

struct UserInterests: Codable {
    var selectedInterests: Set<String>
    var customInterests: [String]
    
    init(selectedInterests: Set<String> = [], customInterests: [String] = []) {
        self.selectedInterests = selectedInterests
        self.customInterests = customInterests
    }
}

// MARK: - Sample Data
extension Celebrity {
    // Static instance for consistent testing
    static let sophiaLeone = Celebrity(
        name: "Sophia Leone",
        occupation: "Adult Film Actress",
        age: 26,
        imageURL: "",
        isDeceased: true,
        deathDate: "March 1, 2024",
        birthDate: "1998-01-01",
        causeOfDeath: "Under investigation (robbery and homicide)",
        nationality: "American",
        netWorth: "$1 million",
        interests: ["Acting", "Modeling", "Adult Industry"],
        isFeatured: true
    )
    
    static let sampleCelebrities: [Celebrity] = [
        Celebrity(
            name: "Robin Williams",
            occupation: "Actor/Comedian",
            age: 63,
            imageURL: "",
            isDeceased: true,
            deathDate: "August 11, 2014",
            birthDate: "July 21, 1951",
            causeOfDeath: "Suicide",
            nationality: "American",
            netWorth: "$50 million",
            interests: ["Comedy", "Acting", "Gaming", "Cycling"],
            isFeatured: true
        ),
        Celebrity(
            name: "David Bowie",
            occupation: "Musician",
            age: 69,
            imageURL: "",
            isDeceased: true,
            deathDate: "January 10, 2016",
            birthDate: "January 8, 1947",
            causeOfDeath: "Liver cancer",
            nationality: "British",
            netWorth: "$230 million",
            interests: ["Music", "Art", "Fashion", "Space"],
            isFeatured: true
        ),
        Celebrity(
            name: "Prince",
            occupation: "Musician",
            age: 57,
            imageURL: "",
            isDeceased: true,
            deathDate: "April 21, 2016",
            birthDate: "June 7, 1958",
            causeOfDeath: "Accidental overdose",
            nationality: "American",
            netWorth: "$300 million",
            interests: ["Music", "Basketball", "Purple", "Religion"],
            isFeatured: true
        ),
        Celebrity(
            name: "Tom Hanks",
            occupation: "Actor",
            age: 67,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "July 9, 1956",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$400 million",
            interests: ["Acting", "Typewriters", "Space", "History"],
            isFeatured: false
        ),
        Celebrity(
            name: "Meryl Streep",
            occupation: "Actress",
            age: 74,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "June 22, 1949",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$160 million",
            interests: ["Acting", "Theater", "Politics", "Environment"],
            isFeatured: false
        ),
        Celebrity(
            name: "Morgan Freeman",
            occupation: "Actor",
            age: 87,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "June 1, 1937",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$250 million",
            interests: ["Acting", "Flying", "Beekeeping", "Narration"],
            isFeatured: false
        ),
        Celebrity(
            name: "Betty White",
            occupation: "Actress",
            age: 99,
            imageURL: "",
            isDeceased: true,
            deathDate: "December 31, 2021",
            birthDate: "January 17, 1922",
            causeOfDeath: "Natural causes",
            nationality: "American",
            netWorth: "$75 million",
            interests: ["Acting", "Animals", "Comedy", "Television"],
            isFeatured: true
        ),
        Celebrity(
            name: "Chadwick Boseman",
            occupation: "Actor",
            age: 43,
            imageURL: "",
            isDeceased: true,
            deathDate: "August 28, 2020",
            birthDate: "November 29, 1976",
            causeOfDeath: "Colon cancer",
            nationality: "American",
            netWorth: "$12 million",
            interests: ["Acting", "Black History", "Comics", "Dance"],
            isFeatured: true
        ),
        Celebrity(
            name: "Michael Jackson",
            occupation: "Singer",
            age: 50,
            imageURL: "",
            isDeceased: true,
            deathDate: "June 25, 2009",
            birthDate: "August 29, 1958",
            causeOfDeath: "Cardiac arrest",
            nationality: "American",
            netWorth: "$500 million",
            interests: ["Music", "Dance"],
            isFeatured: true
        ),
        Celebrity(
            name: "Anna Nicole Smith",
            occupation: "Model/Actress",
            age: 39,
            imageURL: "",
            isDeceased: true,
            deathDate: "February 8, 2007",
            birthDate: "November 28, 1967",
            causeOfDeath: "Drug overdose",
            nationality: "American",
            netWorth: "$1 million",
            interests: ["Fashion", "Adult Industry"],
            isFeatured: false
        ),
        Celebrity(
            name: "Brittany Murphy",
            occupation: "Actress",
            age: 32,
            imageURL: "",
            isDeceased: true,
            deathDate: "December 20, 2009",
            birthDate: "November 10, 1977",
            causeOfDeath: "Pneumonia",
            nationality: "American",
            netWorth: "$10 million",
            interests: ["Film", "Music"],
            isFeatured: false
        ),
        Celebrity(
            name: "Michelle Trachtenberg",
            occupation: "Actress",
            age: 39,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "October 11, 1985",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$9 million",
            interests: ["TV", "Film"],
            isFeatured: false
        ),
        Celebrity.sophiaLeone,
        Celebrity(
            name: "Princess Diana",
            occupation: "Princess",
            age: 36,
            imageURL: "",
            isDeceased: true,
            deathDate: "August 31, 1997",
            birthDate: "July 1, 1961",
            causeOfDeath: "Car accident",
            nationality: "British",
            netWorth: "$25 million",
            interests: ["Charity", "Fashion"],
            isFeatured: true
        ),
        Celebrity(
            name: "Roberta Flack",
            occupation: "Singer",
            age: 87,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "February 10, 1937",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$20 million",
            interests: ["Music"],
            isFeatured: false
        ),
        Celebrity(
            name: "Bernie Mac",
            occupation: "Comedian/Actor",
            age: 50,
            imageURL: "",
            isDeceased: true,
            deathDate: "August 9, 2008",
            birthDate: "October 5, 1957",
            causeOfDeath: "Pneumonia",
            nationality: "American",
            netWorth: "$15 million",
            interests: ["Comedy", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "D'Wayne Wiggins",
            occupation: "Musician",
            age: 63,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "February 14, 1961",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$8 million",
            interests: ["Music"],
            isFeatured: false
        ),
        Celebrity(
            name: "David Johansen",
            occupation: "Singer/Actor",
            age: 74,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "January 9, 1950",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$2 million",
            interests: ["Music", "Film"],
            isFeatured: false
        ),
        Celebrity(
            name: "Dayle Haddon",
            occupation: "Model/Actress",
            age: 76,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "May 26, 1948",
            causeOfDeath: nil,
            nationality: "Canadian",
            netWorth: "$1 million",
            interests: ["Fashion", "Film"],
            isFeatured: false
        ),
        Celebrity(
            name: "Gene Hackman",
            occupation: "Actor",
            age: 94,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "January 30, 1930",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$80 million",
            interests: ["Film"],
            isFeatured: false
        ),
        Celebrity(
            name: "Greg Gumbel",
            occupation: "Sportscaster",
            age: 78,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "May 3, 1946",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$16 million",
            interests: ["Sports", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "Irv Gotti",
            occupation: "Record Producer",
            age: 54,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "June 26, 1970",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$14 million",
            interests: ["Music", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "Jill Clayburgh",
            occupation: "Actress",
            age: 66,
            imageURL: "",
            isDeceased: true,
            deathDate: "November 5, 2010",
            birthDate: "April 30, 1944",
            causeOfDeath: "Leukemia",
            nationality: "American",
            netWorth: "$4 million",
            interests: ["Film", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "Jimmy Carter",
            occupation: "Politician",
            age: 99,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "October 1, 1924",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$10 million",
            interests: ["Politics", "Charity"],
            isFeatured: false
        ),
        Celebrity(
            name: "John Capodice",
            occupation: "Actor",
            age: 82,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "December 25, 1941",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$1 million",
            interests: ["Film", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "John Hughes",
            occupation: "Director/Writer",
            age: 59,
            imageURL: "",
            isDeceased: true,
            deathDate: "August 6, 2009",
            birthDate: "February 18, 1950",
            causeOfDeath: "Heart attack",
            nationality: "American",
            netWorth: "$150 million",
            interests: ["Film", "Writing"],
            isFeatured: false
        ),
        Celebrity(
            name: "Linda Lavin",
            occupation: "Actress",
            age: 87,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "October 15, 1937",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$10 million",
            interests: ["TV", "Theater"],
            isFeatured: false
        ),
        Celebrity(
            name: "Olivia Hussey",
            occupation: "Actress",
            age: 73,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "April 17, 1951",
            causeOfDeath: nil,
            nationality: "British",
            netWorth: "$8 million",
            interests: ["Film", "Theater"],
            isFeatured: false
        ),
        Celebrity(
            name: "Peter Boyle",
            occupation: "Actor",
            age: 71,
            imageURL: "",
            isDeceased: true,
            deathDate: "December 12, 2006",
            birthDate: "October 18, 1935",
            causeOfDeath: "Multiple myeloma",
            nationality: "American",
            netWorth: "$8 million",
            interests: ["Film", "TV"],
            isFeatured: false
        ),
        Celebrity(
            name: "Roy Ayers",
            occupation: "Musician",
            age: 84,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "September 10, 1940",
            causeOfDeath: nil,
            nationality: "American",
            netWorth: "$10 million",
            interests: ["Music", "Jazz"],
            isFeatured: false
        ),
        Celebrity(
            name: "Simon Fisher-Becker",
            occupation: "Actor",
            age: 63,
            imageURL: "",
            isDeceased: false,
            deathDate: nil,
            birthDate: "November 25, 1961",
            causeOfDeath: nil,
            nationality: "British",
            netWorth: "$1 million",
            interests: ["TV", "Film"],
            isFeatured: false
        ),
        Celebrity(
            name: "Whitney Houston",
            occupation: "Singer/Actress",
            age: 48,
            imageURL: "",
            isDeceased: true,
            deathDate: "February 11, 2012",
            birthDate: "August 9, 1963",
            causeOfDeath: "Drowning",
            nationality: "American",
            netWorth: "$20 million",
            interests: ["Music", "Film"],
            isFeatured: true
        ),
        Celebrity(
            name: "Jerry Stiller",
            occupation: "Actor/Comedian",
            age: 92,
            imageURL: "",
            isDeceased: true,
            deathDate: "May 11, 2020",
            birthDate: "June 8, 1927",
            causeOfDeath: "Natural causes",
            nationality: "American",
            netWorth: "$14 million",
            interests: ["Comedy", "TV"],
            isFeatured: false
        )
    ]
}

// MARK: - Available Interests
extension UserInterests {
    static let availableInterests = [
        "Music", "Film", "TV", "Sports", "Comedy", "Art", "Fashion", "Politics",
        "Technology", "Gaming", "Travel", "Food", "Fitness", "Adult Industry", "Literature"
    ]
}

extension Celebrity {
    var deathDateValue: Date? {
        guard let deathDate = self.deathDate else { return nil }
        
        // Try multiple date formats
        let formatters = [
            DateFormatter().apply { $0.dateFormat = "MMMM d, yyyy"; $0.locale = Locale(identifier: "en_US_POSIX") },
            DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd"; $0.locale = Locale(identifier: "en_US_POSIX") },
            DateFormatter().apply { $0.dateFormat = "MMM d, yyyy"; $0.locale = Locale(identifier: "en_US_POSIX") }
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: deathDate) {
                return date
            }
        }
        
        return nil
    }
    
    var birthDateValue: Date? {
        guard let birthDate = self.birthDate else { return nil }
        
        // Try multiple date formats
        let formatters = [
            DateFormatter().apply { $0.dateFormat = "MMMM d, yyyy"; $0.locale = Locale(identifier: "en_US_POSIX") },
            DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd"; $0.locale = Locale(identifier: "en_US_POSIX") },
            DateFormatter().apply { $0.dateFormat = "MMM d, yyyy"; $0.locale = Locale(identifier: "en_US_POSIX") }
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: birthDate) {
                return date
            }
        }
        
        return nil
    }
}

// Helper extension for DateFormatter
extension DateFormatter {
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter {
        block(self)
        return self
    }
}

// MARK: - Social Models
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var username: String
    var displayName: String
    var bio: String?
    var avatarURL: String?
    var joinDate: Date
    @Attribute(.externalStorage) var favoriteCelebrities: [String] // Celebrity names
    @Attribute(.externalStorage) var interests: [String]
    var isVerified: Bool
    var followerCount: Int
    var followingCount: Int
    var tributeCount: Int
    var discussionCount: Int
    var lastActive: Date
    
    init(username: String, displayName: String, bio: String? = nil, avatarURL: String? = nil, interests: [String] = []) {
        self.id = UUID()
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.joinDate = Date()
        self.favoriteCelebrities = []
        self.interests = interests
        self.isVerified = false
        self.followerCount = 0
        self.followingCount = 0
        self.tributeCount = 0
        self.discussionCount = 0
        self.lastActive = Date()
    }
}

@Model
final class Tribute {
    @Attribute(.unique) var id: UUID
    var authorId: UUID
    var celebrityName: String
    var title: String
    var content: String
    @Attribute(.externalStorage) var imageURLs: [String]
    @Attribute(.externalStorage) var tags: [String]
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date
    var updatedAt: Date
    var isEdited: Bool
    
    init(authorId: UUID, celebrityName: String, title: String, content: String, imageURLs: [String] = [], tags: [String] = []) {
        self.id = UUID()
        self.authorId = authorId
        self.celebrityName = celebrityName
        self.title = title
        self.content = content
        self.imageURLs = imageURLs
        self.tags = tags
        self.likeCount = 0
        self.commentCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isEdited = false
    }
}

@Model
final class Discussion {
    @Attribute(.unique) var id: UUID
    var authorId: UUID
    var title: String
    var content: String
    var category: DiscussionCategory
    @Attribute(.externalStorage) var tags: [String]
    var likeCount: Int
    var commentCount: Int
    var viewCount: Int
    var isPinned: Bool
    var isLocked: Bool
    var createdAt: Date
    var updatedAt: Date
    var lastActivityAt: Date
    
    init(authorId: UUID, title: String, content: String, category: DiscussionCategory, tags: [String] = []) {
        self.id = UUID()
        self.authorId = authorId
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.likeCount = 0
        self.commentCount = 0
        self.viewCount = 0
        self.isPinned = false
        self.isLocked = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastActivityAt = Date()
    }
}

@Model
final class Comment {
    @Attribute(.unique) var id: UUID
    var authorId: UUID
    var parentId: UUID? // For nested comments
    var content: String
    var likeCount: Int
    var createdAt: Date
    var updatedAt: Date
    var isEdited: Bool
    var isDeleted: Bool
    
    init(authorId: UUID, content: String, parentId: UUID? = nil) {
        self.id = UUID()
        self.authorId = authorId
        self.parentId = parentId
        self.content = content
        self.likeCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isEdited = false
        self.isDeleted = false
    }
}

@Model
final class Follow {
    @Attribute(.unique) var id: UUID
    var followerId: UUID
    var followingId: UUID
    var createdAt: Date
    
    init(followerId: UUID, followingId: UUID) {
        self.id = UUID()
        self.followerId = followerId
        self.followingId = followingId
        self.createdAt = Date()
    }
}

@Model
final class Like {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var targetId: UUID
    var targetType: LikeTargetType
    var createdAt: Date
    
    init(userId: UUID, targetId: UUID, targetType: LikeTargetType) {
        self.id = UUID()
        self.userId = userId
        self.targetId = targetId
        self.targetType = targetType
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum DiscussionCategory: String, CaseIterable, Codable {
    case general = "General"
    case celebrityNews = "Celebrity News"
    case tributes = "Tributes"
    case predictions = "Predictions"
    case health = "Health & Wellness"
    case entertainment = "Entertainment"
    case offTopic = "Off Topic"
    
    var icon: String {
        switch self {
        case .general: return "bubble.left.and.bubble.right"
        case .celebrityNews: return "newspaper"
        case .tributes: return "heart.fill"
        case .predictions: return "sparkles"
        case .health: return "heart.text.square.fill"
        case .entertainment: return "tv"
        case .offTopic: return "ellipsis.circle"
        }
    }
    
    var color: String {
        switch self {
        case .general: return "blue"
        case .celebrityNews: return "orange"
        case .tributes: return "red"
        case .predictions: return "purple"
        case .health: return "green"
        case .entertainment: return "pink"
        case .offTopic: return "gray"
        }
    }
}

enum LikeTargetType: String, CaseIterable, Codable {
    case tribute = "tribute"
    case discussion = "discussion"
    case comment = "comment"
}

// MARK: - Sample Social Data
extension UserProfile {
    static let sampleProfiles: [UserProfile] = [
        UserProfile(
            username: "celebrity_fan_2024",
            displayName: "Sarah Johnson",
            bio: "Passionate about classic Hollywood and modern entertainment. Always keeping up with celebrity news!",
            avatarURL: "",
            interests: ["Acting", "Music", "Classic Hollywood"]
        ),
        UserProfile(
            username: "movie_buff",
            displayName: "Mike Chen",
            bio: "Film enthusiast and celebrity watcher. Love discussing the impact of stars on culture.",
            avatarURL: "",
            interests: ["Acting", "Film", "Directing"]
        ),
        UserProfile(
            username: "music_lover",
            displayName: "Emma Davis",
            bio: "Music is life! Following musicians and their incredible journeys.",
            avatarURL: "",
            interests: ["Music", "Singing", "Guitar"]
        )
    ]
}

extension Tribute {
    static let sampleTributes: [Tribute] = [
        Tribute(
            authorId: UserProfile.sampleProfiles[0].id,
            celebrityName: "Robin Williams",
            title: "Remembering the Joy He Brought",
            content: "Robin Williams was more than just a comedian - he was a beacon of light in dark times. His ability to make us laugh while also touching our hearts was truly remarkable. I'll never forget watching 'Dead Poets Society' and feeling inspired to seize the day. His legacy lives on in every smile he created.",
            tags: ["Comedy", "Inspiration", "Legacy"]
        ),
        Tribute(
            authorId: UserProfile.sampleProfiles[1].id,
            celebrityName: "David Bowie",
            title: "The Man Who Sold the World",
            content: "David Bowie wasn't just a musician; he was a cultural revolution. His constant reinvention and fearless creativity inspired generations. From Ziggy Stardust to the Thin White Duke, he showed us that it's okay to be different, to be yourself. His music will echo through eternity.",
            tags: ["Music", "Innovation", "Art"]
        )
    ]
}

extension Discussion {
    static let sampleDiscussions: [Discussion] = [
        Discussion(
            authorId: UserProfile.sampleProfiles[0].id,
            title: "Which celebrity death affected you the most?",
            content: "We've all been touched by the loss of celebrities we admired. I'm curious to hear which celebrity's death had the biggest impact on your life and why. For me, it was Robin Williams - his death made me realize how important mental health awareness is.",
            category: .general,
            tags: ["Mental Health", "Impact", "Legacy"]
        ),
        Discussion(
            authorId: UserProfile.sampleProfiles[2].id,
            title: "Predictions for 2024 Celebrity Deaths",
            content: "Based on age, health conditions, and lifestyle factors, which celebrities do you think we might lose this year? This is a sensitive topic, but it's important to be prepared and appreciate them while they're here.",
            category: .predictions,
            tags: ["Predictions", "2024", "Health"]
        )
    ]
}

// MARK: - Additional Enums
enum WatchlistPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var icon: String {
        switch self {
        case .low: return "1.circle"
        case .medium: return "2.circle"
        case .high: return "3.circle"
        case .critical: return "exclamationmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum NotificationType: String, Codable {
    case deathAlert = "death_alert"
    case newTribute = "new_tribute"
    case newDiscussion = "new_discussion"
    case newComment = "new_comment"
    case newFollower = "new_follower"
    case likeReceived = "like_received"
    case watchlistUpdate = "watchlist_update"
    
    var icon: String {
        switch self {
        case .deathAlert: return "heart.slash.fill"
        case .newTribute: return "heart.fill"
        case .newDiscussion: return "bubble.left.and.bubble.right"
        case .newComment: return "text.bubble"
        case .newFollower: return "person.badge.plus"
        case .likeReceived: return "hand.thumbsup.fill"
        case .watchlistUpdate: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .deathAlert: return "red"
        case .newTribute: return "pink"
        case .newDiscussion: return "blue"
        case .newComment: return "green"
        case .newFollower: return "purple"
        case .likeReceived: return "orange"
        case .watchlistUpdate: return "yellow"
        }
    }
}

@Model
final class AppNotification {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var type: NotificationType
    var title: String
    var message: String
    var isRead: Bool
    var createdAt: Date
    var relatedId: UUID?
    var relatedType: String?
    
    init(userId: UUID, type: NotificationType, title: String, message: String, relatedId: UUID? = nil, relatedType: String? = nil) {
        self.id = UUID()
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.isRead = false
        self.createdAt = Date()
        self.relatedId = relatedId
        self.relatedType = relatedType
    }
}

@Model
final class WatchlistItem {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var celebrityName: String
    var addedDate: Date
    var notes: String?
    var priority: WatchlistPriority
    var isPublic: Bool
    
    init(userId: UUID, celebrityName: String, notes: String? = nil, priority: WatchlistPriority = .medium, isPublic: Bool = true) {
        self.id = UUID()
        self.userId = userId
        self.celebrityName = celebrityName
        self.addedDate = Date()
        self.notes = notes
        self.priority = priority
        self.isPublic = isPublic
    }
}

// MARK: - Sample Watchlist Data
extension WatchlistItem {
    static let sampleWatchlistItems: [WatchlistItem] = [
        WatchlistItem(
            userId: UserProfile.sampleProfiles[0].id,
            celebrityName: "Morgan Freeman",
            notes: "One of the greatest actors of all time",
            priority: .high,
            isPublic: true
        ),
        WatchlistItem(
            userId: UserProfile.sampleProfiles[0].id,
            celebrityName: "Meryl Streep",
            notes: "Incredible talent and longevity",
            priority: .critical,
            isPublic: true
        ),
        WatchlistItem(
            userId: UserProfile.sampleProfiles[1].id,
            celebrityName: "Tom Hanks",
            notes: "America's favorite actor",
            priority: .high,
            isPublic: true
        ),
        WatchlistItem(
            userId: UserProfile.sampleProfiles[2].id,
            celebrityName: "Paul McCartney",
            notes: "Musical legend",
            priority: .critical,
            isPublic: true
        )
    ]
}

// MARK: - Gamification Models
@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var title: String
    var achievementDescription: String
    var iconName: String
    var category: AchievementCategory
    var requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    var points: Int
    
    init(title: String, achievementDescription: String, iconName: String, category: AchievementCategory, requirement: Int, points: Int = 10) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = achievementDescription
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.isUnlocked = false
        self.unlockedDate = nil
        self.points = points
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case following = "Following"
    case trivia = "Trivia"
    case predictions = "Predictions"
    case engagement = "Engagement"
    case milestones = "Milestones"
}

@Model
final class TriviaQuestion {
    @Attribute(.unique) var id: UUID
    var question: String
    var correctAnswer: String
    @Attribute(.externalStorage) var options: [String]
    var category: String
    var difficulty: TriviaDifficulty
    var points: Int
    var isAnswered: Bool
    var answeredDate: Date?
    var userAnswer: String?
    var isCorrect: Bool?
    
    init(question: String, correctAnswer: String, options: [String], category: String, difficulty: TriviaDifficulty, points: Int) {
        self.id = UUID()
        self.question = question
        self.correctAnswer = correctAnswer
        self.options = options
        self.category = category
        self.difficulty = difficulty
        self.points = points
        self.isAnswered = false
        self.answeredDate = nil
        self.userAnswer = nil
        self.isCorrect = nil
    }
}

enum TriviaDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var points: Int {
        switch self {
        case .easy: return 5
        case .medium: return 10
        case .hard: return 20
        }
    }
}

@Model
final class Prediction {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var celebrityName: String
    var predictedDate: Date
    var confidence: Int // 1-100
    var isResolved: Bool
    var actualDate: Date?
    var points: Int
    var isCorrect: Bool?
    var createdAt: Date
    
    init(celebrityId: UUID, celebrityName: String, predictedDate: Date, confidence: Int) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.celebrityName = celebrityName
        self.predictedDate = predictedDate
        self.confidence = max(1, min(100, confidence))
        self.isResolved = false
        self.actualDate = nil
        self.points = 0
        self.isCorrect = nil
        self.createdAt = Date()
    }
}

@Model
final class UserProgress {
    @Attribute(.unique) var id: UUID
    var totalPoints: Int
    var level: Int
    var experiencePoints: Int
    var experienceToNextLevel: Int
    var achievementsUnlocked: Int
    var triviaAnswered: Int
    var triviaCorrect: Int
    var predictionsMade: Int
    var predictionsCorrect: Int
    var celebritiesFollowed: Int
    var lastUpdated: Date
    
    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.level = 1
        self.experiencePoints = 0
        self.experienceToNextLevel = 100
        self.achievementsUnlocked = 0
        self.triviaAnswered = 0
        self.triviaCorrect = 0
        self.predictionsMade = 0
        self.predictionsCorrect = 0
        self.celebritiesFollowed = 0
        self.lastUpdated = Date()
    }
    
    func addExperience(_ points: Int) {
        self.experiencePoints += points
        self.totalPoints += points
        
        // Check for level up
        while experiencePoints >= experienceToNextLevel {
            levelUp()
        }
        
        self.lastUpdated = Date()
    }
    
    private func levelUp() {
        self.level += 1
        self.experiencePoints -= experienceToNextLevel
        self.experienceToNextLevel = level * 100 // Simple progression
    }
}

// MARK: - Sample Gamification Data
extension Achievement {
    static let sampleAchievements: [Achievement] = [
        Achievement(
            title: "First Steps",
            achievementDescription: "Follow your first celebrity",
            iconName: "person.badge.plus",
            category: .following,
            requirement: 1,
            points: 10
        ),
        Achievement(
            title: "Celebrity Enthusiast",
            achievementDescription: "Follow 10 celebrities",
            iconName: "person.3.sequence",
            category: .following,
            requirement: 10,
            points: 25
        ),
        Achievement(
            title: "Celebrity Expert",
            achievementDescription: "Follow 50 celebrities",
            iconName: "person.3.sequence.fill",
            category: .following,
            requirement: 50,
            points: 50
        ),
        Achievement(
            title: "Celebrity Master",
            achievementDescription: "Follow 100 celebrities",
            iconName: "crown.fill",
            category: .following,
            requirement: 100,
            points: 100
        ),
        Achievement(
            title: "Trivia Novice",
            achievementDescription: "Answer your first trivia question",
            iconName: "questionmark.circle",
            category: .trivia,
            requirement: 1,
            points: 10
        ),
        Achievement(
            title: "Trivia Expert",
            achievementDescription: "Answer 10 trivia questions correctly",
            iconName: "questionmark.circle.fill",
            category: .trivia,
            requirement: 10,
            points: 50
        ),
        Achievement(
            title: "Crystal Ball",
            achievementDescription: "Make your first prediction",
            iconName: "crystal.ball",
            category: .predictions,
            requirement: 1,
            points: 15
        ),
        Achievement(
            title: "Fortune Teller",
            achievementDescription: "Make 5 correct predictions",
            iconName: "crystal.ball.fill",
            category: .predictions,
            requirement: 5,
            points: 75
        ),
        Achievement(
            title: "Social Butterfly",
            achievementDescription: "Create 5 discussions",
            iconName: "bubble.left.and.bubble.right",
            category: .engagement,
            requirement: 5,
            points: 30
        ),
        Achievement(
            title: "Tribute Master",
            achievementDescription: "Create 10 tributes",
            iconName: "heart.text.square",
            category: .engagement,
            requirement: 10,
            points: 60
        )
    ]
}

extension TriviaQuestion {
    static let sampleQuestions: [TriviaQuestion] = [
        TriviaQuestion(
            question: "Which actor played the role of Black Panther in the Marvel Cinematic Universe?",
            correctAnswer: "Chadwick Boseman",
            options: ["Chadwick Boseman", "Michael B. Jordan", "Idris Elba", "Denzel Washington"],
            category: "Actors",
            difficulty: .easy,
            points: 5
        ),
        TriviaQuestion(
            question: "What was the cause of death for Robin Williams?",
            correctAnswer: "Suicide",
            options: ["Heart attack", "Cancer", "Suicide", "Car accident"],
            category: "Celebrity Deaths",
            difficulty: .medium,
            points: 10
        ),
        TriviaQuestion(
            question: "Which musician was known as 'The King of Pop'?",
            correctAnswer: "Michael Jackson",
            options: ["Elvis Presley", "Michael Jackson", "Prince", "David Bowie"],
            category: "Music",
            difficulty: .easy,
            points: 5
        ),
        TriviaQuestion(
            question: "What year did Princess Diana die?",
            correctAnswer: "1997",
            options: ["1995", "1996", "1997", "1998"],
            category: "Celebrity Deaths",
            difficulty: .medium,
            points: 10
        ),
        TriviaQuestion(
            question: "Which actor has won the most Academy Awards for acting?",
            correctAnswer: "Katharine Hepburn",
            options: ["Meryl Streep", "Katharine Hepburn", "Jack Nicholson", "Daniel Day-Lewis"],
            category: "Actors",
            difficulty: .hard,
            points: 20
        ),
        TriviaQuestion(
            question: "What was Betty White's age when she passed away?",
            correctAnswer: "99",
            options: ["95", "97", "99", "101"],
            category: "Celebrity Deaths",
            difficulty: .medium,
            points: 10
        ),
        TriviaQuestion(
            question: "Which musician died in 2016 and was known for his flamboyant style and purple theme?",
            correctAnswer: "Prince",
            options: ["David Bowie", "Prince", "George Michael", "Leonard Cohen"],
            category: "Music",
            difficulty: .medium,
            points: 10
        ),
        TriviaQuestion(
            question: "What was the occupation of Sophia Leone?",
            correctAnswer: "Adult Film Actress",
            options: ["Singer", "Actress", "Adult Film Actress", "Model"],
            category: "Celebrities",
            difficulty: .hard,
            points: 20
        )
    ]
}

// MARK: - Rich Media Models
@Model
final class CelebrityMedia {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var type: MediaType
    var title: String
    var mediaDescription: String?
    var url: String
    var thumbnailURL: String?
    var duration: TimeInterval? // For videos
    var createdAt: Date
    var isFeatured: Bool
    
    init(celebrityId: UUID, type: MediaType, title: String, url: String, mediaDescription: String? = nil, thumbnailURL: String? = nil, duration: TimeInterval? = nil, isFeatured: Bool = false) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.type = type
        self.title = title
        self.mediaDescription = mediaDescription
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.isFeatured = isFeatured
        self.createdAt = Date()
    }
}

@Model
final class CelebrityQuote {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var quoteText: String
    var context: String?
    var source: String?
    var year: Int?
    var isVerified: Bool
    var createdAt: Date
    
    init(celebrityId: UUID, quoteText: String, context: String? = nil, source: String? = nil, year: Int? = nil, isVerified: Bool = false) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.quoteText = quoteText
        self.context = context
        self.source = source
        self.year = year
        self.isVerified = isVerified
        self.createdAt = Date()
    }
}

@Model
final class CareerHighlight {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var title: String
    var highlightDescription: String
    var year: Int
    var category: CareerCategory
    var significance: String?
    var imageURL: String?
    var createdAt: Date
    
    init(celebrityId: UUID, title: String, highlightDescription: String, year: Int, category: CareerCategory, significance: String? = nil, imageURL: String? = nil) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.title = title
        self.highlightDescription = highlightDescription
        self.year = year
        self.category = category
        self.significance = significance
        self.imageURL = imageURL
        self.createdAt = Date()
    }
}

@Model
final class CelebrityBiography {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var earlyLife: String
    var career: String
    var personalLife: String?
    var legacy: String?
    var achievements: String?
    var lastUpdated: Date
    
    init(celebrityId: UUID, earlyLife: String, career: String, personalLife: String? = nil, legacy: String? = nil, achievements: String? = nil) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.earlyLife = earlyLife
        self.career = career
        self.personalLife = personalLife
        self.legacy = legacy
        self.achievements = achievements
        self.lastUpdated = Date()
    }
}

@Model
final class CelebrityAnalytics {
    @Attribute(.unique) var id: UUID
    var celebrityId: UUID
    var viewCount: Int
    var tributeCount: Int
    var watchlistCount: Int
    var trendingScore: Double
    var lastUpdated: Date
    
    init(celebrityId: UUID) {
        self.id = UUID()
        self.celebrityId = celebrityId
        self.viewCount = 0
        self.tributeCount = 0
        self.watchlistCount = 0
        self.trendingScore = 0.0
        self.lastUpdated = Date()
    }
}

// MARK: - Enums
enum MediaType: String, Codable, CaseIterable {
    case photo = "photo"
    case video = "video"
    case audio = "audio"
    
    var icon: String {
        switch self {
        case .photo: return "photo"
        case .video: return "video"
        case .audio: return "waveform"
        }
    }
}

enum CareerCategory: String, Codable, CaseIterable {
    case breakthrough = "Breakthrough"
    case award = "Award"
    case collaboration = "Collaboration"
    case innovation = "Innovation"
    case comeback = "Comeback"
    case retirement = "Retirement"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .breakthrough: return "star.fill"
        case .award: return "trophy.fill"
        case .collaboration: return "person.2.fill"
        case .innovation: return "lightbulb.fill"
        case .comeback: return "arrow.clockwise"
        case .retirement: return "flag.fill"
        case .other: return "ellipsis.circle"
        }
    }
    
    var color: String {
        switch self {
        case .breakthrough: return "yellow"
        case .award: return "orange"
        case .collaboration: return "blue"
        case .innovation: return "purple"
        case .comeback: return "green"
        case .retirement: return "gray"
        case .other: return "secondary"
        }
    }
} 
