//
//  Models.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation

// MARK: - Data Models
struct Celebrity: Identifiable, Codable {
    let id = UUID()
    let name: String
    let occupation: String
    let age: Int
    let imageURL: String
    let isDeceased: Bool
    let deathDate: String?
    let birthDate: String?
    let causeOfDeath: String?
    let nationality: String?
    let netWorth: String?
    let interests: [String]
    let isFeatured: Bool
    
    init(name: String, occupation: String, age: Int, imageURL: String, isDeceased: Bool, deathDate: String?, birthDate: String?, causeOfDeath: String? = nil, nationality: String? = nil, netWorth: String? = nil, interests: [String] = [], isFeatured: Bool = false) {
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