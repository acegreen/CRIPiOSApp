//
//  GamificationViewModel.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class GamificationViewModel {
    private var modelContext: ModelContext?
    var currentUser: UserProfile?
    var userProgress: UserProgress?
    var achievements: [Achievement] = []
    var triviaQuestions: [TriviaQuestion] = []
    var predictions: [Prediction] = []
    var dailyTriviaQuestion: TriviaQuestion?
    var showAchievementUnlocked = false
    var unlockedAchievement: Achievement?
    var showLevelUp = false
    var newLevel: Int = 1
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        if modelContext != nil {
            setupGamification()
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        setupGamification()
    }
    
    private func setupGamification() {
        // Initialize user progress if it doesn't exist
        if userProgress == nil {
            userProgress = UserProgress()
            modelContext?.insert(userProgress!)
        }
        
        // Load or create achievements
        loadAchievements()
        
        // Load or create trivia questions
        loadTriviaQuestions()
        
        // Set daily trivia question
        setDailyTriviaQuestion()
        
        // Load predictions
        loadPredictions()
    }
    
    private func loadAchievements() {
        do {
            let descriptor = FetchDescriptor<Achievement>()
            achievements = try modelContext?.fetch(descriptor) ?? []
            
            if achievements.isEmpty {
                // Create sample achievements
                achievements = Achievement.sampleAchievements
                for achievement in achievements {
                    modelContext?.insert(achievement)
                }
            }
        } catch {
            print("Error loading achievements: \(error)")
        }
    }
    
    private func loadTriviaQuestions() {
        do {
            let descriptor = FetchDescriptor<TriviaQuestion>()
            triviaQuestions = try modelContext?.fetch(descriptor) ?? []
            
            if triviaQuestions.isEmpty {
                // Create sample trivia questions
                triviaQuestions = TriviaQuestion.sampleQuestions
                for question in triviaQuestions {
                    modelContext?.insert(question)
                }
            }
        } catch {
            print("Error loading trivia questions: \(error)")
        }
    }
    
    private func loadPredictions() {
        do {
            let descriptor = FetchDescriptor<Prediction>()
            predictions = try modelContext?.fetch(descriptor) ?? []
        } catch {
            print("Error loading predictions: \(error)")
        }
    }
    
    private func setDailyTriviaQuestion() {
        let unansweredQuestions = triviaQuestions.filter { !$0.isAnswered }
        if let randomQuestion = unansweredQuestions.randomElement() {
            dailyTriviaQuestion = randomQuestion
        } else {
            // Reset all questions if all have been answered
            for question in triviaQuestions {
                question.isAnswered = false
                question.answeredDate = nil
                question.userAnswer = nil
                question.isCorrect = nil
            }
            dailyTriviaQuestion = triviaQuestions.randomElement()
        }
    }
    
    // MARK: - Achievement Management
    func checkAchievements() {
        guard let progress = userProgress else { return }
        
        for achievement in achievements where !achievement.isUnlocked {
            if shouldUnlockAchievement(achievement, progress: progress) {
                unlockAchievement(achievement)
            }
        }
    }
    
    private func shouldUnlockAchievement(_ achievement: Achievement, progress: UserProgress) -> Bool {
        switch achievement.category {
        case .following:
            return progress.celebritiesFollowed >= achievement.requirement
        case .trivia:
            return progress.triviaCorrect >= achievement.requirement
        case .predictions:
            return progress.predictionsCorrect >= achievement.requirement
        case .engagement:
            // This would need to be updated based on actual engagement metrics
            return false
        case .milestones:
            return progress.level >= achievement.requirement
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        
        if let progress = userProgress {
            progress.achievementsUnlocked += 1
            progress.addExperience(achievement.points)
        }
        
        unlockedAchievement = achievement
        showAchievementUnlocked = true
        
        // Check for level up
        if let progress = userProgress, progress.level > newLevel {
            newLevel = progress.level
            showLevelUp = true
        }
        
        saveContext()
    }
    
    // MARK: - Trivia Management
    func answerTriviaQuestion(_ question: TriviaQuestion, answer: String) {
        question.isAnswered = true
        question.answeredDate = Date()
        question.userAnswer = answer
        question.isCorrect = answer == question.correctAnswer
        
        if let progress = userProgress {
            progress.triviaAnswered += 1
            if question.isCorrect == true {
                progress.triviaCorrect += 1
                progress.addExperience(question.points)
            }
        }
        
        checkAchievements()
        saveContext()
        
        // Set new daily question
        setDailyTriviaQuestion()
    }
    
    // MARK: - Prediction Management
    func createPrediction(celebrityId: UUID, celebrityName: String, predictedDate: Date, confidence: Int) {
        let prediction = Prediction(
            celebrityId: celebrityId,
            celebrityName: celebrityName,
            predictedDate: predictedDate,
            confidence: confidence
        )
        
        modelContext?.insert(prediction)
        predictions.append(prediction)
        
        if let progress = userProgress {
            progress.predictionsMade += 1
            progress.addExperience(5) // Small points for making prediction
        }
        
        checkAchievements()
        saveContext()
    }
    
    func resolvePrediction(_ prediction: Prediction, actualDate: Date?) {
        prediction.isResolved = true
        prediction.actualDate = actualDate
        
        if let actualDate = actualDate {
            let calendar = Calendar.current
            let daysDifference = calendar.dateComponents([.day], from: prediction.predictedDate, to: actualDate).day ?? 0
            
            // Calculate points based on accuracy
            let accuracy = max(0, 100 - abs(daysDifference))
            prediction.points = accuracy / 10 // 0-10 points based on accuracy
            
            if let progress = userProgress {
                progress.addExperience(prediction.points)
                
                if abs(daysDifference) <= 30 { // Within 30 days is considered "correct"
                    progress.predictionsCorrect += 1
                    prediction.isCorrect = true
                } else {
                    prediction.isCorrect = false
                }
            }
        }
        
        checkAchievements()
        saveContext()
    }
    
    // MARK: - Progress Management
    func updateCelebritiesFollowed(_ count: Int) {
        if let progress = userProgress {
            progress.celebritiesFollowed = count
            progress.addExperience(1) // Small points for following
            checkAchievements()
            saveContext()
        }
    }
    
    func getProgressPercentage() -> Double {
        guard let progress = userProgress else { return 0.0 }
        let currentXP = Double(progress.experiencePoints)
        let requiredXP = Double(progress.experienceToNextLevel)
        return min(currentXP / requiredXP, 1.0)
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func getLockedAchievements() -> [Achievement] {
        return achievements.filter { !$0.isUnlocked }
    }
    
    func getAchievementsByCategory(_ category: AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }
    
    func getTriviaStats() -> (answered: Int, correct: Int, accuracy: Double) {
        guard let progress = userProgress else { return (0, 0, 0.0) }
        let accuracy = progress.triviaAnswered > 0 ? Double(progress.triviaCorrect) / Double(progress.triviaAnswered) : 0.0
        return (progress.triviaAnswered, progress.triviaCorrect, accuracy)
    }
    
    func getPredictionStats() -> (made: Int, correct: Int, accuracy: Double) {
        guard let progress = userProgress else { return (0, 0, 0.0) }
        let accuracy = progress.predictionsMade > 0 ? Double(progress.predictionsCorrect) / Double(progress.predictionsMade) : 0.0
        return (progress.predictionsMade, progress.predictionsCorrect, accuracy)
    }
    
    // MARK: - Utility Methods
    private func saveContext() {
        do {
            try modelContext?.save()
        } catch {
            print("Error saving gamification context: \(error)")
        }
    }
} 