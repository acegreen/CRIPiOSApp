import SwiftUI

struct CelebrityRowView: View {
    let celebrity: Celebrity
    var viewModel: CelebrityViewModel
    @State private var loadedImageURL: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        HStack(spacing: 12) {
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
                } else if !celebrity.imageURL.isEmpty, let imageURL = URL(string: celebrity.imageURL) {
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
                        .onAppear {
                            if !isLoading {
                                isLoading = true
                                Task {
                                    loadedImageURL = await viewModel.imageURL(for: celebrity)
                                    isLoading = false
                                }
                            }
                        }
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            
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
                
                // Interests
                if !celebrity.interests.isEmpty {
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
            
            Spacer()
            
            if celebrity.isDeceased {
                Image(systemName: "heart.slash.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 24))
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "heart.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
                    .frame(width: 64, height: 64)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 
