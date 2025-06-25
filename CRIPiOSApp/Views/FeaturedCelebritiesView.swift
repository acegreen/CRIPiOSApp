//
//  FeaturedCelebritiesView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct FeaturedCelebritiesView: View {
    var viewModel: CelebrityViewModel
    var socialViewModel: SocialViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Celebrities")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if socialViewModel.isLoggedIn && !viewModel.userInterests.selectedInterests.isEmpty {
                    Text("Personalized")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(getFeaturedCelebrities().prefix(10)) { celebrity in
                        FeaturedCelebrityCard(celebrity: celebrity,
                                              userInterests: viewModel.userInterests,
                                              viewModel: viewModel,
                                              socialViewModel: socialViewModel,
                                              isLoggedIn: socialViewModel.isLoggedIn)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getFeaturedCelebrities() -> [Celebrity] {
        if socialViewModel.isLoggedIn {
            return viewModel.getPersonalizedFeaturedCelebrities()
        } else {
            return viewModel.getFeaturedCelebrities()
        }
    }
}

struct FeaturedCelebrityCard: View {
    let celebrity: Celebrity
    let userInterests: UserInterests
    var viewModel: CelebrityViewModel
    var socialViewModel: SocialViewModel
    let isLoggedIn: Bool
    @State private var loadedImageURL: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationLink(destination: CelebrityDetailView(celebrity: celebrity,
                                                        viewModel: viewModel, socialViewModel: socialViewModel)) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                Group {
                    if let url = loadedImageURL, let imageURL = URL(string: url) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 128, height: 128)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            celebrity.isDeceased ? Color.accentColor : Color.green,
                            lineWidth: 3
                        )
                )
                .onAppear {
                    if loadedImageURL == nil && !isLoading {
                        isLoading = true
                        Task {
                            loadedImageURL = await viewModel.imageURL(for: celebrity)
                            isLoading = false
                        }
                    }
                }
                
                // Name and Status
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(celebrity.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if celebrity.isFeatured {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                    }
                    
                    Text(celebrity.occupation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if celebrity.isDeceased {
                        Text("Died: \(celebrity.deathDate ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    } else {
                        Text("Age: \(celebrity.age)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Matching Interests (only show if logged in)
                if isLoggedIn && !userInterests.selectedInterests.isEmpty {
                    let matchingInterests = celebrity.interests.filter { userInterests.selectedInterests.contains($0) }
                    if !matchingInterests.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Interests:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(matchingInterests.prefix(3), id: \.self) { interest in
                                        Text(interest)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // All Interests
                if !celebrity.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Interests:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(celebrity.interests.prefix(3), id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.secondary)
                                        .cornerRadius(4)
                                }
                                
                                if celebrity.interests.count > 3 {
                                    Text("+\(celebrity.interests.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(width: 160)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
