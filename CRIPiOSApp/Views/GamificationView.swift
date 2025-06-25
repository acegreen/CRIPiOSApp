//
//  GamificationView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct GamificationView: View {
    @State var gamificationViewModel: GamificationViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user progress
                UserProgressHeader(gamificationViewModel: gamificationViewModel)
                
                // Tab selector
                CustomTabSelector(selectedTab: $selectedTab)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    AchievementsView(gamificationViewModel: gamificationViewModel)
                        .tag(0)
                    
                    TriviaView(gamificationViewModel: gamificationViewModel)
                        .tag(1)
                    
                    PredictionsView(gamificationViewModel: gamificationViewModel)
                        .tag(2)
                    
                    GamificationStatsView(gamificationViewModel: gamificationViewModel)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Gamification")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $gamificationViewModel.showAchievementUnlocked) {
            if let achievement = gamificationViewModel.unlockedAchievement {
                AchievementUnlockedView(achievement: achievement)
            }
        }
        .sheet(isPresented: $gamificationViewModel.showLevelUp) {
            LevelUpView(level: gamificationViewModel.newLevel)
        }
    }
}

// MARK: - User Progress Header
struct UserProgressHeader: View {
    @Bindable var gamificationViewModel: GamificationViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let progress = gamificationViewModel.userProgress {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(progress.level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("\(progress.totalPoints) Total Points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(progress.experiencePoints)/\(progress.experienceToNextLevel) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Next Level")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress bar
                ProgressView(value: gamificationViewModel.getProgressPercentage())
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Custom Tab Selector
struct CustomTabSelector: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("trophy.fill", "Achievements"),
        ("questionmark.circle.fill", "Trivia"),
        ("crystal.ball.fill", "Predictions"),
        ("chart.bar.fill", "Stats")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                        
                        Text(tabs[index].1)
                            .font(.caption)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    @State private var selectedCategory: AchievementCategory = .following
    
    var body: some View {
        VStack(spacing: 16) {
            // Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Achievements list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(gamificationViewModel.getAchievementsByCategory(selectedCategory), id: \.id) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Achievement Row
struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue : Color(.systemGray4))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked {
                    Text("+\(achievement.points) points")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Text("\(achievement.requirement)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Trivia View
struct TriviaView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var showingMemoryChallenge = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Memory Challenge Button
                Button(action: {
                    showingMemoryChallenge = true
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Memory Challenge")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Test your celebrity knowledge")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                if let question = gamificationViewModel.dailyTriviaQuestion {
                    // Question card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Daily Trivia")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text(question.difficulty.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(difficultyColor(question.difficulty))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Text(question.question)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                        
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button(action: {
                                    if !showResult {
                                        selectedAnswer = option
                                        showResult = true
                                        gamificationViewModel.answerTriviaQuestion(question, answer: option)
                                    }
                                }) {
                                    HStack {
                                        Text(option)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        if showResult {
                                            if option == question.correctAnswer {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else if option == selectedAnswer && option != question.correctAnswer {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(answerBackgroundColor(option))
                                    .foregroundColor(answerTextColor(option))
                                    .cornerRadius(8)
                                }
                                .disabled(showResult)
                            }
                        }
                        
                        if showResult {
                            VStack(spacing: 8) {
                                Text(selectedAnswer == question.correctAnswer ? "Correct!" : "Incorrect!")
                                    .font(.headline)
                                    .foregroundColor(selectedAnswer == question.correctAnswer ? .green : .red)
                                
                                if selectedAnswer == question.correctAnswer {
                                    Text("+\(question.points) points")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                } else {
                    Text("No trivia questions available")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingMemoryChallenge) {
            MemoryChallengeView(gamificationViewModel: gamificationViewModel)
        }
    }
    
    private func difficultyColor(_ difficulty: TriviaDifficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private func answerBackgroundColor(_ option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? Color.blue.opacity(0.1) : Color(.systemGray6)
        } else {
            if option == gamificationViewModel.dailyTriviaQuestion?.correctAnswer {
                return Color.green.opacity(0.2)
            } else if option == selectedAnswer && option != gamificationViewModel.dailyTriviaQuestion?.correctAnswer {
                return Color.red.opacity(0.2)
            } else {
                return Color(.systemGray6)
            }
        }
    }
    
    private func answerTextColor(_ option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? .blue : .primary
        } else {
            if option == gamificationViewModel.dailyTriviaQuestion?.correctAnswer {
                return .green
            } else if option == selectedAnswer && option != gamificationViewModel.dailyTriviaQuestion?.correctAnswer {
                return .red
            } else {
                return .primary
            }
        }
    }
}

// MARK: - Predictions View
struct PredictionsView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    @State private var showingCreatePrediction = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Your Predictions")
                    .font(.headline)
                
                Spacer()
                
                Button("New Prediction") {
                    showingCreatePrediction = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            // Predictions list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(gamificationViewModel.predictions, id: \.id) { prediction in
                        PredictionRow(prediction: prediction)
                    }
                    
                    if gamificationViewModel.predictions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "crystal.ball")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No predictions yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Make your first prediction to start earning points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingCreatePrediction) {
            CreatePredictionView(gamificationViewModel: gamificationViewModel)
        }
    }
}

// MARK: - Prediction Row
struct PredictionRow: View {
    let prediction: Prediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(prediction.celebrityName)
                    .font(.headline)
                
                Spacer()
                
                if prediction.isResolved {
                    if prediction.isCorrect == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                } else {
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Predicted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(prediction.predictedDate, style: .date)
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(prediction.confidence)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            if prediction.isResolved && prediction.points > 0 {
                HStack {
                    Text("+\(prediction.points) points")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Statistics View
struct GamificationStatsView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Trivia Stats
                GamificationStatCard(
                    title: "Trivia Performance",
                    icon: "questionmark.circle.fill",
                    color: .blue
                ) {
                    let stats = gamificationViewModel.getTriviaStats()
                    VStack(spacing: 8) {
                        StatRow(title: "Questions Answered", value: "\(stats.answered)")
                        StatRow(title: "Correct Answers", value: "\(stats.correct)")
                        StatRow(title: "Accuracy", value: "\(Int(stats.accuracy * 100))%")
                    }
                }
                
                // Prediction Stats
                GamificationStatCard(
                    title: "Prediction Performance",
                    icon: "crystal.ball.fill",
                    color: .purple
                ) {
                    let stats = gamificationViewModel.getPredictionStats()
                    VStack(spacing: 8) {
                        StatRow(title: "Predictions Made", value: "\(stats.made)")
                        StatRow(title: "Correct Predictions", value: "\(stats.correct)")
                        StatRow(title: "Accuracy", value: "\(Int(stats.accuracy * 100))%")
                    }
                }
                
                // Achievement Stats
                GamificationStatCard(
                    title: "Achievements",
                    icon: "trophy.fill",
                    color: .orange
                ) {
                    VStack(spacing: 8) {
                        StatRow(title: "Unlocked", value: "\(gamificationViewModel.getUnlockedAchievements().count)")
                        StatRow(title: "Total", value: "\(gamificationViewModel.achievements.count)")
                        StatRow(title: "Completion", value: "\(Int(Double(gamificationViewModel.getUnlockedAchievements().count) / Double(gamificationViewModel.achievements.count) * 100))%")
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Stat Card
struct GamificationStatCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Achievement Unlocked View
struct AchievementUnlockedView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(spacing: 8) {
                Text("Achievement Unlocked!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(achievement.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(achievement.achievementDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("+\(achievement.points) points")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Button("Continue") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Level Up View
struct LevelUpView: View {
    let level: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(spacing: 8) {
                Text("Level Up!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Congratulations! You've reached level \(level)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Keep playing to unlock more achievements and climb higher!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Continue") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Create Prediction View
struct CreatePredictionView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCelebrity: Celebrity?
    @State private var predictedDate = Date()
    @State private var confidence: Double = 50
    
    var body: some View {
        NavigationView {
            Form {
                Section("Celebrity") {
                    // This would need to be connected to the celebrity list
                    Text("Select a celebrity to predict")
                        .foregroundColor(.secondary)
                }
                
                Section("Prediction") {
                    DatePicker("Predicted Date", selection: $predictedDate, displayedComponents: .date)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confidence: \(Int(confidence))%")
                            .font(.subheadline)
                        
                        Slider(value: $confidence, in: 1...100, step: 1)
                    }
                }
            }
            .navigationTitle("New Prediction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if let celebrity = selectedCelebrity {
                            gamificationViewModel.createPrediction(
                                celebrityId: celebrity.id,
                                celebrityName: celebrity.name,
                                predictedDate: predictedDate,
                                confidence: Int(confidence)
                            )
                            dismiss()
                        }
                    }
                    .disabled(selectedCelebrity == nil)
                }
            }
        }
    }
} 
