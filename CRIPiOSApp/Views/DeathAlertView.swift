import SwiftUI

struct DeathAlertView: View {
    let celebrities: [Celebrity]
    let onDismiss: () -> Void
    
    var body: some View {
        // Alert content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                    
                    Text("Death Alert")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("We've detected that the following celebrity(ies) have passed away:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        ForEach(celebrities) { celebrity in
                            DeathAlertCard(celebrity: celebrity)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                
                // Footer
                VStack(spacing: 12) {
                    Button(action: onDismiss) {
                        Text("Dismiss")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Text("You can view more details in the Celebrities tab")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .padding()
            .background(Color(.systemBackground))
    }
}

struct DeathAlertCard: View {
    let celebrity: Celebrity
    
    var body: some View {
        HStack(spacing: 12) {
            // Celebrity image
            Group {
                if !celebrity.imageURL.isEmpty, let imageURL = URL(string: celebrity.imageURL) {
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
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Celebrity info
            VStack(alignment: .leading, spacing: 8) {
                Text(celebrity.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(celebrity.occupation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let deathDate = celebrity.deathDate {
                    Text("Died: \(deathDate)")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .fontWeight(.medium)
                }
                
                if let causeOfDeath = celebrity.causeOfDeath {
                    Text(causeOfDeath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Status indicator
            Image(systemName: "heart.slash.fill")
                .foregroundColor(.accentColor)
                .font(.title3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DeathAlertView(
        celebrities: [Celebrity.sophiaLeone]
    ) {
        // Alert dismissed
    }
} 