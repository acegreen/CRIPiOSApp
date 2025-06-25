//
//  AnalyticsService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftData

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Advanced Analytics Methods
    
    func calculateMortalityRate(by occupation: String, celebrities: [Celebrity]) -> Double {
        let occupationCelebrities = celebrities.filter { $0.occupation == occupation }
        guard !occupationCelebrities.isEmpty else { return 0 }
        
        let deceasedCount = occupationCelebrities.filter { $0.isDeceased }.count
        return Double(deceasedCount) / Double(occupationCelebrities.count) * 100
    }
    
    func calculateLifeExpectancy(by occupation: String, celebrities: [Celebrity]) -> Double {
        let deceasedCelebrities = celebrities.filter { $0.isDeceased && $0.occupation == occupation }
        guard !deceasedCelebrities.isEmpty else { return 0 }
        
        let totalAge = deceasedCelebrities.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(deceasedCelebrities.count)
    }
    
    func identifySeasonalPatterns(celebrities: [Celebrity]) -> [Int: Int] {
        var monthlyDeaths: [Int: Int] = [:]
        
        for celebrity in celebrities where celebrity.isDeceased {
            if let deathDate = celebrity.deathDateValue {
                let month = Calendar.current.component(.month, from: deathDate)
                monthlyDeaths[month, default: 0] += 1
            }
        }
        
        return monthlyDeaths
    }
    
    func calculateRiskFactors(for celebrity: Celebrity, allCelebrities: [Celebrity]) -> [RiskFactor] {
        var factors: [RiskFactor] = []
        
        // Age factor
        if celebrity.age > 80 {
            factors.append(RiskFactor(type: .age, severity: .high, description: "Advanced age (80+)", impact: 25))
        } else if celebrity.age > 70 {
            factors.append(RiskFactor(type: .age, severity: .medium, description: "Elderly (70+)", impact: 15))
        }
        
        // Occupation factor
        let occupationRisk = calculateMortalityRate(by: celebrity.occupation, celebrities: allCelebrities)
        if occupationRisk > 50 {
            factors.append(RiskFactor(type: .occupation, severity: .high, description: "High-risk occupation", impact: 20))
        } else if occupationRisk > 30 {
            factors.append(RiskFactor(type: .occupation, severity: .medium, description: "Moderate-risk occupation", impact: 10))
        }
        
        // Interest-based factors
        let highRiskInterests = ["Adult Industry", "Drugs", "Extreme Sports"]
        let riskInterests = celebrity.interests.filter { highRiskInterests.contains($0) }
        if !riskInterests.isEmpty {
            factors.append(RiskFactor(type: .lifestyle, severity: .high, description: "High-risk interests", impact: 15))
        }
        
        // Nationality factor (simplified)
        if celebrity.nationality == "American" {
            factors.append(RiskFactor(type: .demographic, severity: .low, description: "American nationality", impact: 5))
        }
        
        return factors
    }
    
    func predictLifespan(for celebrity: Celebrity, allCelebrities: [Celebrity]) -> LifespanPrediction {
        let riskFactors = calculateRiskFactors(for: celebrity, allCelebrities: allCelebrities)
        let totalRiskImpact = riskFactors.reduce(0) { $0 + $1.impact }
        
        // Base life expectancy calculation
        let baseLifespan = 85
        let riskReduction = Int(totalRiskImpact * 0.4) // Convert risk to years
        let predictedLifespan = max(baseLifespan - riskReduction, celebrity.age + 1)
        
        // Confidence calculation
        let confidence = calculatePredictionConfidence(for: celebrity, riskFactors: riskFactors)
        
        return LifespanPrediction(
            celebrityId: celebrity.id,
            celebrityName: celebrity.name,
            predictedLifespan: predictedLifespan,
            confidence: confidence,
            riskFactors: riskFactors,
            totalRiskScore: totalRiskImpact
        )
    }
    
    func analyzeDeathTrends(celebrities: [Celebrity]) -> ServiceDeathTrendsAnalysis {
        let deceasedCelebrities = celebrities.filter { $0.isDeceased }
        
        // Age distribution
        let ageDistribution = analyzeAgeDistribution(deceasedCelebrities)
        
        // Cause of death analysis
        let causeAnalysis = analyzeCausesOfDeath(deceasedCelebrities)
        
        // Temporal patterns
        let temporalPatterns = analyzeTemporalPatterns(deceasedCelebrities)
        
        // Occupation analysis
        let occupationAnalysis = analyzeOccupationPatterns(deceasedCelebrities)
        
        // Convert to DeathTrendsAnalysis format
        let occupationRisk = occupationAnalysis.mapValues { stats in
            Double(stats.count) / Double(deceasedCelebrities.count) * 100
        }
        
        return ServiceDeathTrendsAnalysis(
            ageDistribution: ageDistribution,
            occupationRisk: occupationRisk,
            causeOfDeathDistribution: causeAnalysis,
            yearlyTrends: temporalPatterns.yearlyPatterns,
            monthlyPatterns: temporalPatterns.monthlyPatterns
        )
    }
    
    func generateInsights(celebrities: [Celebrity]) -> [AnalyticsInsight] {
        var insights: [AnalyticsInsight] = []
        
        let serviceTrends = analyzeDeathTrends(celebrities: celebrities)
        
        // Convert to DeathTrendsAnalysis format for compatibility
        let trends = DeathTrendsAnalysis(
            ageDistribution: serviceTrends.ageDistribution,
            occupationRisk: serviceTrends.occupationRisk,
            causeOfDeathDistribution: serviceTrends.causeOfDeathDistribution,
            yearlyTrends: serviceTrends.yearlyTrends,
            monthlyPatterns: serviceTrends.monthlyPatterns
        )
        
        // Age-based insights
        if let mostCommonAgeGroup = trends.ageDistribution.max(by: { $0.value < $1.value }) {
            insights.append(AnalyticsInsight(
                type: .age,
                title: "Most Common Age at Death",
                description: "The \(mostCommonAgeGroup.key.rawValue) age group has the highest mortality rate",
                significance: mostCommonAgeGroup.value > 5 ? .high : .medium,
                data: mostCommonAgeGroup.value
            ))
        }
        
        // Cause-based insights
        if let mostCommonCause = trends.causeOfDeathDistribution.max(by: { $0.value < $1.value }) {
            insights.append(AnalyticsInsight(
                type: .cause,
                title: "Leading Cause of Death",
                description: "\(mostCommonCause.key) is the most common cause of death among celebrities",
                significance: mostCommonCause.value > 3 ? .high : .medium,
                data: mostCommonCause.value
            ))
        }
        
        // Seasonal insights
        if let peakMonth = trends.monthlyPatterns.max(by: { $0.value < $1.value }) {
            let monthName = monthNameFromNumber(peakMonth.key)
            insights.append(AnalyticsInsight(
                type: .temporal,
                title: "Seasonal Pattern",
                description: "\(monthName) has the highest number of celebrity deaths",
                significance: peakMonth.value > 2 ? .medium : .low,
                data: peakMonth.value
            ))
        }
        
        return insights
    }
    
    // MARK: - Private Helper Methods
    
    private func calculatePredictionConfidence(for celebrity: Celebrity, riskFactors: [RiskFactor]) -> Double {
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
        
        // Adjust based on number of risk factors
        if riskFactors.count > 3 {
            confidence += 10
        }
        
        return min(max(confidence, 30), 95) // Between 30-95%
    }
    
    private func analyzeAgeDistribution(_ celebrities: [Celebrity]) -> [AgeGroup: Int] {
        var distribution: [AgeGroup: Int] = [:]
        
        for group in AgeGroup.allCases {
            distribution[group] = celebrities.filter { group.range.contains($0.age) }.count
        }
        
        return distribution
    }
    
    private func analyzeCausesOfDeath(_ celebrities: [Celebrity]) -> [String: Int] {
        let causes = Dictionary(grouping: celebrities, by: { $0.causeOfDeath ?? "Unknown" })
            .mapValues { $0.count }
        return causes.sorted { $0.value > $1.value }
            .reduce(into: [:]) { result, element in
                result[element.key] = element.value
            }
    }
    
    private func analyzeTemporalPatterns(_ celebrities: [Celebrity]) -> TemporalPatterns {
        var yearlyPatterns: [Int: Int] = [:]
        var monthlyPatterns: [Int: Int] = [:]
        
        for celebrity in celebrities {
            if let deathDate = celebrity.deathDateValue {
                let year = Calendar.current.component(.year, from: deathDate)
                let month = Calendar.current.component(.month, from: deathDate)
                
                yearlyPatterns[year, default: 0] += 1
                monthlyPatterns[month, default: 0] += 1
            }
        }
        
        return TemporalPatterns(
            yearlyPatterns: yearlyPatterns,
            monthlyPatterns: monthlyPatterns
        )
    }
    
    private func analyzeOccupationPatterns(_ celebrities: [Celebrity]) -> [String: OccupationStats] {
        let occupationGroups = Dictionary(grouping: celebrities, by: { $0.occupation })
        
        return occupationGroups.mapValues { group in
            let averageAge = Double(group.map { $0.age }.reduce(0, +)) / Double(group.count)
            let causes = Dictionary(grouping: group, by: { $0.causeOfDeath ?? "Unknown" })
                .mapValues { $0.count }
            
            return OccupationStats(
                count: group.count,
                averageAge: averageAge,
                topCauses: causes.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
            )
        }
    }
    
    private func monthNameFromNumber(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Data Models

struct RiskFactor {
    let type: RiskFactorType
    let severity: RiskSeverity
    let description: String
    let impact: Double
}

enum RiskFactorType {
    case age
    case occupation
    case lifestyle
    case demographic
    case health
}

enum RiskSeverity {
    case low
    case medium
    case high
    case critical
}

struct LifespanPrediction {
    let celebrityId: UUID
    let celebrityName: String
    let predictedLifespan: Int
    let confidence: Double
    let riskFactors: [RiskFactor]
    let totalRiskScore: Double
}

struct ServiceDeathTrendsAnalysis {
    let ageDistribution: [AgeGroup: Int]
    let occupationRisk: [String: Double]
    let causeOfDeathDistribution: [String: Int]
    let yearlyTrends: [Int: Int]
    let monthlyPatterns: [Int: Int]
}

// MARK: - Supporting Data Models

struct TemporalPatterns {
    let yearlyPatterns: [Int: Int]
    let monthlyPatterns: [Int: Int]
}

struct OccupationStats {
    let count: Int
    let averageAge: Double
    let topCauses: [String]
}

struct AnalyticsInsight {
    let type: InsightType
    let title: String
    let description: String
    let significance: InsightSignificance
    let data: Int
}

enum InsightType: String, CaseIterable {
    case age = "age"
    case cause = "cause"
    case temporal = "temporal"
    case occupation = "occupation"
    case demographic = "demographic"
}

enum InsightSignificance: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
} 
