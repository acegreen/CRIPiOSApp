//
//  AnalyticsViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class AnalyticsViewModel {
    private var modelContext: ModelContext?
    var isLoading = false
    var errorMessage: String?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Setup
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Statistics Methods
    
    func getStatistics(for timeframe: Timeframe, celebrities: [Celebrity]) -> CelebrityStatistics {
        let filteredCelebrities = getCelebritiesForTimeframe(timeframe, celebrities: celebrities)
        let total = filteredCelebrities.count
        let deceased = filteredCelebrities.filter { $0.isDeceased }.count
        let living = total - deceased
        
        let averageAge = filteredCelebrities.map { $0.age }.reduce(0, +) / max(filteredCelebrities.count, 1)
        
        let occupations = Dictionary(grouping: filteredCelebrities, by: { $0.occupation })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let interests = Dictionary(grouping: filteredCelebrities.flatMap { $0.interests }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return CelebrityStatistics(
            total: total,
            deceased: deceased,
            living: living,
            averageAge: averageAge,
            topOccupations: Array(occupations.prefix(5)),
            topInterests: Array(interests.prefix(5))
        )
    }
    
    // MARK: - Death Trends Analysis
    
    func getDeathTrendsAnalysis(for timeframe: Timeframe, celebrities: [Celebrity]) -> DeathTrendsAnalysis {
        let filteredCelebrities = getCelebritiesForTimeframe(timeframe, celebrities: celebrities)
        let deceasedCelebrities = filteredCelebrities.filter { $0.isDeceased }
        
        // Age distribution
        var ageDistribution: [AgeGroup: Int] = [:]
        for group in AgeGroup.allCases {
            ageDistribution[group] = deceasedCelebrities.filter { group.range.contains($0.age) }.count
        }
        
        // Occupation risk analysis
        let occupationRisk = calculateOccupationRisk(for: timeframe, celebrities: celebrities)
        
        // Cause of death distribution
        let causeDistribution = Dictionary(grouping: deceasedCelebrities, by: { $0.causeOfDeath ?? "Unknown" })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        // Yearly trends
        var yearlyTrends: [Int: Int] = [:]
        for celebrity in deceasedCelebrities {
            if let deathDate = celebrity.deathDateValue {
                let year = Calendar.current.component(.year, from: deathDate)
                yearlyTrends[year, default: 0] += 1
            }
        }
        
        // Monthly patterns
        var monthlyPatterns: [Int: Int] = [:]
        for celebrity in deceasedCelebrities {
            if let deathDate = celebrity.deathDateValue {
                let month = Calendar.current.component(.month, from: deathDate)
                monthlyPatterns[month, default: 0] += 1
            }
        }
        
        return DeathTrendsAnalysis(
            ageDistribution: ageDistribution,
            occupationRisk: occupationRisk,
            causeOfDeathDistribution: Dictionary(uniqueKeysWithValues: causeDistribution.map { ($0.key, $0.value) }),
            yearlyTrends: yearlyTrends,
            monthlyPatterns: monthlyPatterns
        )
    }
    
    // MARK: - Longevity Predictions
    
    func getLongevityPredictions(celebrities: [Celebrity]) -> [LongevityPrediction] {
        let livingCelebrities = celebrities.filter { !$0.isDeceased }
        
        return livingCelebrities.map { celebrity in
            let riskScore = calculateRiskScore(for: celebrity)
            let predictedLifespan = calculatePredictedLifespan(for: celebrity)
            let riskFactors = identifyRiskFactors(for: celebrity)
            let confidence = calculatePredictionConfidence(for: celebrity)
            
            return LongevityPrediction(
                celebrityId: celebrity.id,
                celebrityName: celebrity.name,
                riskScore: riskScore,
                predictedLifespan: predictedLifespan,
                riskFactors: riskFactors,
                confidence: confidence
            )
        }.sorted { $0.riskScore > $1.riskScore }
    }
    
    // MARK: - Historical Comparison
    
    func getHistoricalComparison(celebrities: [Celebrity]) -> HistoricalComparison {
        let deceasedCelebrities = celebrities.filter { $0.isDeceased }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentDecadeStart = (currentYear / 10) * 10
        let previousDecadeStart = currentDecadeStart - 10
        
        let currentDecadeDeaths = deceasedCelebrities.filter { celebrity in
            guard let deathDate = celebrity.deathDateValue else { return false }
            let deathYear = Calendar.current.component(.year, from: deathDate)
            return deathYear >= currentDecadeStart
        }
        
        let previousDecadeDeaths = deceasedCelebrities.filter { celebrity in
            guard let deathDate = celebrity.deathDateValue else { return false }
            let deathYear = Calendar.current.component(.year, from: deathDate)
            return deathYear >= previousDecadeStart && deathYear < currentDecadeStart
        }
        
        let currentDecadeStats = calculateDecadeStats(deaths: currentDecadeDeaths, decade: "\(currentDecadeStart)s")
        let previousDecadeStats = calculateDecadeStats(deaths: previousDecadeDeaths, decade: "\(previousDecadeStart)s")
        
        let trendAnalysis = analyzeTrends(current: currentDecadeStats, previous: previousDecadeStats)
        
        return HistoricalComparison(
            currentDecade: currentDecadeStats,
            previousDecade: previousDecadeStats,
            trendAnalysis: trendAnalysis
        )
    }
    
    // MARK: - Helper Methods
    
    private func getCelebritiesForTimeframe(_ timeframe: Timeframe, celebrities: [Celebrity]) -> [Celebrity] {
        switch timeframe {
        case .lastYear:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return celebrities.filter { celebrity in
                if celebrity.isDeceased, let deathDate = celebrity.deathDateValue {
                    return deathDate >= oneYearAgo
                }
                return true // Include living celebrities
            }
        case .last5Years:
            let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
            return celebrities.filter { celebrity in
                if celebrity.isDeceased, let deathDate = celebrity.deathDateValue {
                    return deathDate >= fiveYearsAgo
                }
                return true
            }
        case .last10Years:
            let tenYearsAgo = Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
            return celebrities.filter { celebrity in
                if celebrity.isDeceased, let deathDate = celebrity.deathDateValue {
                    return deathDate >= tenYearsAgo
                }
                return true
            }
        case .allTime:
            return celebrities
        }
    }
    
    private func calculateOccupationRisk(for timeframe: Timeframe, celebrities: [Celebrity]) -> [String: Double] {
        let deceasedCelebrities = celebrities.filter { $0.isDeceased }
        
        let occupationGroups = Dictionary(grouping: celebrities, by: { $0.occupation })
        var occupationRisk: [String: Double] = [:]
        
        for (occupation, group) in occupationGroups {
            let totalInOccupation = group.count
            let deceasedInOccupation = group.filter { $0.isDeceased }.count
            let riskPercentage = totalInOccupation > 0 ? Double(deceasedInOccupation) / Double(totalInOccupation) * 100 : 0
            occupationRisk[occupation] = riskPercentage
        }
        
        return occupationRisk.sorted { $0.value > $1.value }
            .reduce(into: [:]) { result, element in
                result[element.key] = element.value
            }
    }
    
    private func calculateRiskScore(for celebrity: Celebrity) -> Double {
        var riskScore: Double = 0
        
        // Age factor (higher age = higher risk)
        riskScore += Double(celebrity.age) * 0.5
        
        // Occupation risk factor
        let occupationRisk = calculateOccupationRisk(for: .allTime, celebrities: [celebrity])
        if let risk = occupationRisk[celebrity.occupation] {
            riskScore += risk * 0.3
        }
        
        // Nationality factor (simplified - could be enhanced with actual data)
        if celebrity.nationality == "American" {
            riskScore += 10 // Base risk for Americans
        }
        
        // Interest-based risk factors
        let highRiskInterests = ["Adult Industry", "Drugs", "Extreme Sports"]
        let riskInterests = celebrity.interests.filter { highRiskInterests.contains($0) }
        riskScore += Double(riskInterests.count) * 15
        
        return min(riskScore, 100) // Cap at 100
    }
    
    private func calculatePredictedLifespan(for celebrity: Celebrity) -> Int {
        let baseLifespan = 85 // Base life expectancy
        let riskScore = calculateRiskScore(for: celebrity)
        
        // Reduce lifespan based on risk score
        let reduction = Int(riskScore * 0.3)
        return max(baseLifespan - reduction, celebrity.age + 1)
    }
    
    private func identifyRiskFactors(for celebrity: Celebrity) -> [String] {
        var factors: [String] = []
        
        if celebrity.age > 70 {
            factors.append("Advanced age")
        }
        
        let highRiskOccupations = ["Adult Film Actress", "Musician", "Actor"]
        if highRiskOccupations.contains(celebrity.occupation) {
            factors.append("High-risk occupation")
        }
        
        let riskInterests = celebrity.interests.filter { ["Adult Industry", "Drugs"].contains($0) }
        if !riskInterests.isEmpty {
            factors.append("High-risk interests")
        }
        
        return factors
    }
    
    private func calculatePredictionConfidence(for celebrity: Celebrity) -> Double {
        var confidence: Double = 70 // Base confidence
        
        // Higher confidence for older celebrities
        if celebrity.age > 80 {
            confidence += 20
        } else if celebrity.age < 40 {
            confidence -= 20
        }
        
        // Adjust based on data quality
        if celebrity.causeOfDeath != nil {
            confidence += 10
        }
        
        return min(max(confidence, 30), 95) // Between 30-95%
    }
    
    private func calculateDecadeStats(deaths: [Celebrity], decade: String) -> DecadeStats {
        let averageAge = deaths.isEmpty ? 0 : Double(deaths.map { $0.age }.reduce(0, +)) / Double(deaths.count)
        
        let causeDistribution = Dictionary(grouping: deaths, by: { $0.causeOfDeath ?? "Unknown" })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let occupationDistribution = Dictionary(grouping: deaths, by: { $0.occupation })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return DecadeStats(
            decade: decade,
            averageAge: averageAge,
            topCauses: Dictionary(uniqueKeysWithValues: causeDistribution.prefix(5).map { ($0.key, $0.value) }),
            topOccupations: Dictionary(uniqueKeysWithValues: occupationDistribution.prefix(5).map { ($0.key, $0.value) }),
            totalDeaths: deaths.count
        )
    }
    
    private func analyzeTrends(current: DecadeStats, previous: DecadeStats) -> String {
        let ageDifference = current.averageAge - previous.averageAge
        let deathDifference = current.totalDeaths - previous.totalDeaths
        
        var analysis = "Comparing \(current.decade) to \(previous.decade): "
        
        if ageDifference > 0 {
            analysis += "Average age at death increased by \(String(format: "%.1f", ageDifference)) years. "
        } else {
            analysis += "Average age at death decreased by \(String(format: "%.1f", abs(ageDifference))) years. "
        }
        
        if deathDifference > 0 {
            analysis += "Total deaths increased by \(deathDifference). "
        } else {
            analysis += "Total deaths decreased by \(abs(deathDifference)). "
        }
        
        return analysis
    }
}

// MARK: - Analytics Models
struct CelebrityStatistics {
    let total: Int
    let deceased: Int
    let living: Int
    let averageAge: Int
    let topOccupations: [(String, Int)]
    let topInterests: [(String, Int)]
}

struct DeathTrendsAnalysis {
    let ageDistribution: [AgeGroup: Int]
    let occupationRisk: [String: Double]
    let causeOfDeathDistribution: [String: Int]
    let yearlyTrends: [Int: Int]
    let monthlyPatterns: [Int: Int]
}

struct LongevityPrediction {
    let celebrityId: UUID
    let celebrityName: String
    let riskScore: Double
    let predictedLifespan: Int
    let riskFactors: [String]
    let confidence: Double
}

struct HistoricalComparison {
    let currentDecade: DecadeStats
    let previousDecade: DecadeStats
    let trendAnalysis: String
}

struct DecadeStats {
    let decade: String
    let averageAge: Double
    let topCauses: [String: Int]
    let topOccupations: [String: Int]
    let totalDeaths: Int
}

enum AgeGroup: String, CaseIterable {
    case under30 = "Under 30"
    case thirtyTo40 = "30-40"
    case fortyTo50 = "40-50"
    case fiftyTo60 = "50-60"
    case sixtyTo70 = "60-70"
    case seventyTo80 = "70-80"
    case over80 = "Over 80"
    
    var range: ClosedRange<Int> {
        switch self {
        case .under30: return 0...29
        case .thirtyTo40: return 30...40
        case .fortyTo50: return 41...50
        case .fiftyTo60: return 51...60
        case .sixtyTo70: return 61...70
        case .seventyTo80: return 71...80
        case .over80: return 81...120
        }
    }
}

enum Timeframe: String, CaseIterable {
    case lastYear = "lastYear"
    case last5Years = "last5Years"
    case last10Years = "last10Years"
    case allTime = "allTime"

    var displayName: String {
        switch self {
        case .lastYear: return "1Y"
        case .last5Years: return "5Y"
        case .last10Years: return "10Y"
        case .allTime: return "All"
        }
    }
} 