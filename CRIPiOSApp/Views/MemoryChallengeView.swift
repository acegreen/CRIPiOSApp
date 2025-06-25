//
//  MemoryChallengeView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct MemoryChallengeView: View {
    @Bindable var gamificationViewModel: GamificationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var selectedAnswer: String?
    @State private var questions: [MemoryQuestion] = []
    @State private var gameStarted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !gameStarted {
                    // Start screen
                    VStack(spacing: 24) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Memory Challenge")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Test your knowledge about celebrities! Answer questions about their lives, careers, and facts.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Start Challenge") {
                            startGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                    .padding()
                } else if currentQuestionIndex < questions.count {
                    // Game screen
                    VStack(spacing: 20) {
                        // Progress indicator
                        HStack {
                            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Score: \(score)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        // Progress bar
                        ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        // Question
                        VStack(alignment: .leading, spacing: 16) {
                            Text(questions[currentQuestionIndex].question)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                                    Button(action: {
                                        if selectedAnswer == nil {
                                            selectedAnswer = option
                                            showResult = true
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                nextQuestion()
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(option)
                                                .font(.body)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if showResult {
                                                if option == questions[currentQuestionIndex].correctAnswer {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                } else if option == selectedAnswer && option != questions[currentQuestionIndex].correctAnswer {
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
                                    .disabled(selectedAnswer != nil)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Results screen
                    VStack(spacing: 24) {
                        Image(systemName: score > questions.count / 2 ? "star.fill" : "star")
                            .font(.system(size: 60))
                            .foregroundColor(score > questions.count / 2 ? .yellow : .gray)
                        
                        Text("Challenge Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            Text("Final Score: \(score)/\(questions.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Accuracy: \(Int(Double(score) / Double(questions.count) * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if score > questions.count / 2 {
                            Text("Great job! You have excellent celebrity knowledge!")
                                .font(.body)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Keep learning! Try again to improve your score.")
                                .font(.body)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Play Again") {
                            resetGame()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .navigationTitle("Memory Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if gameStarted && currentQuestionIndex < questions.count {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Exit") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func startGame() {
        questions = generateMemoryQuestions()
        gameStarted = true
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
    }
    
    private func nextQuestion() {
        if selectedAnswer == questions[currentQuestionIndex].correctAnswer {
            score += 1
        }
        
        currentQuestionIndex += 1
        selectedAnswer = nil
        showResult = false
        
        // Award points based on performance
        if currentQuestionIndex >= questions.count {
            let accuracy = Double(score) / Double(questions.count)
            let points = Int(accuracy * 50) // 0-50 points based on accuracy
            gamificationViewModel.userProgress?.addExperience(points)
        }
    }
    
    private func resetGame() {
        gameStarted = false
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        questions = []
    }
    
    private func answerBackgroundColor(_ option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? Color.blue.opacity(0.1) : Color(.systemBackground)
        } else {
            if option == questions[currentQuestionIndex].correctAnswer {
                return Color.green.opacity(0.2)
            } else if option == selectedAnswer && option != questions[currentQuestionIndex].correctAnswer {
                return Color.red.opacity(0.2)
            } else {
                return Color(.systemBackground)
            }
        }
    }
    
    private func answerTextColor(_ option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? .blue : .primary
        } else {
            if option == questions[currentQuestionIndex].correctAnswer {
                return .green
            } else if option == selectedAnswer && option != questions[currentQuestionIndex].correctAnswer {
                return .red
            } else {
                return .primary
            }
        }
    }
    
    private func generateMemoryQuestions() -> [MemoryQuestion] {
        return [
            MemoryQuestion(
                question: "Which actor played the role of Black Panther in the Marvel Cinematic Universe?",
                correctAnswer: "Chadwick Boseman",
                options: ["Chadwick Boseman", "Michael B. Jordan", "Idris Elba", "Denzel Washington"]
            ),
            MemoryQuestion(
                question: "What was the cause of death for Robin Williams?",
                correctAnswer: "Suicide",
                options: ["Heart attack", "Cancer", "Suicide", "Car accident"]
            ),
            MemoryQuestion(
                question: "Which musician was known as 'The King of Pop'?",
                correctAnswer: "Michael Jackson",
                options: ["Elvis Presley", "Michael Jackson", "Prince", "David Bowie"]
            ),
            MemoryQuestion(
                question: "What year did Princess Diana die?",
                correctAnswer: "1997",
                options: ["1995", "1996", "1997", "1998"]
            ),
            MemoryQuestion(
                question: "What was Betty White's age when she passed away?",
                correctAnswer: "99",
                options: ["95", "97", "99", "101"]
            ),
            MemoryQuestion(
                question: "Which musician died in 2016 and was known for his flamboyant style and purple theme?",
                correctAnswer: "Prince",
                options: ["David Bowie", "Prince", "George Michael", "Leonard Cohen"]
            ),
            MemoryQuestion(
                question: "What was the occupation of Sophia Leone?",
                correctAnswer: "Adult Film Actress",
                options: ["Singer", "Actress", "Adult Film Actress", "Model"]
            ),
            MemoryQuestion(
                question: "Which actor has won the most Academy Awards for acting?",
                correctAnswer: "Katharine Hepburn",
                options: ["Meryl Streep", "Katharine Hepburn", "Jack Nicholson", "Daniel Day-Lewis"]
            ),
            MemoryQuestion(
                question: "What was the nationality of David Bowie?",
                correctAnswer: "British",
                options: ["American", "British", "Canadian", "Australian"]
            ),
            MemoryQuestion(
                question: "Which celebrity was known for their love of typewriters?",
                correctAnswer: "Tom Hanks",
                options: ["Tom Hanks", "Morgan Freeman", "Meryl Streep", "Gene Hackman"]
            )
        ].shuffled()
    }
}

struct MemoryQuestion {
    let question: String
    let correctAnswer: String
    let options: [String]
}
