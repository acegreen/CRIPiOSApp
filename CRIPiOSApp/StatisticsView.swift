//
//  StatisticsView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: CelebrityViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Celebrities",
                        value: "\(viewModel.getStatistics().total)",
                        icon: "person.3.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Living",
                        value: "\(viewModel.getStatistics().living)",
                        icon: "heart.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Deceased",
                        value: "\(viewModel.getStatistics().deceased)",
                        icon: "heart.slash.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "Average Age",
                        value: "\(viewModel.getStatistics().averageAge)",
                        icon: "calendar",
                        color: .orange
                    )
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Top Occupations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Occupations")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(viewModel.getStatistics().topOccupations, id: \.0) { occupation, count in
                            HStack {
                                Text(occupation)
                                    .font(.body)
                                Spacer()
                                Text("\(count)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Top Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Interests")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(viewModel.getStatistics().topInterests, id: \.0) { interest, count in
                            HStack {
                                Text(interest)
                                    .font(.body)
                                Spacer()
                                Text("\(count)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Recent Deaths Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Deaths")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        let recentDeaths = viewModel.getRecentDeaths().prefix(5)
                        ForEach(Array(recentDeaths.enumerated()), id: \.element.id) { index, celebrity in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(width: 30, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(celebrity.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    if let deathDate = celebrity.deathDate {
                                        Text(deathDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if let causeOfDeath = celebrity.causeOfDeath {
                                    Text(causeOfDeath)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatisticsView(viewModel: CelebrityViewModel())
} 