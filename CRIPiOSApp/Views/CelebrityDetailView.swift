import SwiftUI

struct CelebrityDetailView: View {
    let celebrity: Celebrity
    var viewModel: CelebrityViewModel
    var socialViewModel: SocialViewModel
    @State private var loadedImageURL: String? = nil
    @State private var isLoading = false
    @State private var selectedTab = 0
    @State private var showingCreateTribute = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Loading state if celebrity data is not properly loaded
                if celebrity.name.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading celebrity details...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    // Header
                    HStack {
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
                        .frame(width: 128, height: 128)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(celebrity.name)
                                    .font(.title)
                                    .fontWeight(.bold)

                                if celebrity.isFeatured {
                                    Image(systemName: "star.fill")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                }
                            }

                            Text(celebrity.occupation)
                                .font(.title3)
                                .foregroundColor(.secondary)

                            if celebrity.isDeceased {
                                Text("Deceased")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.2))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(8)
                            } else {
                                Text("Living")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            }
                        }

                        Spacer()
                    }

                    // Social Actions
                    if socialViewModel.isLoggedIn {
                        HStack(spacing: 12) {
                            Button(action: { showingCreateTribute = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "heart.fill")
                                    Text("Create Tribute")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                            }

                            Button(action: {
                                if socialViewModel.isInWatchlist(celebrityName: celebrity.name) {
                                    socialViewModel.removeFromWatchlist(celebrityName: celebrity.name)
                                } else {
                                    socialViewModel.addToWatchlist(celebrityName: celebrity.name)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: socialViewModel.isInWatchlist(celebrityName: celebrity.name) ? "heart.slash.fill" : "heart")
                                    Text(socialViewModel.isInWatchlist(celebrityName: celebrity.name) ? "Remove from Watchlist" : "Add to Watchlist")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(socialViewModel.isInWatchlist(celebrityName: celebrity.name) ? .red : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(socialViewModel.isInWatchlist(celebrityName: celebrity.name) ? Color.red.opacity(0.1) : Color.green)
                                .cornerRadius(8)
                            }

                            Spacer()
                        }
                    }

                    // Content Tabs
                    VStack(spacing: 0) {
                        // Tab Picker
                        HStack(spacing: 0) {
                            TabButton(
                                title: "Details",
                                isSelected: selectedTab == 0,
                                action: { selectedTab = 0 }
                            )

                            TabButton(
                                title: "Media",
                                isSelected: selectedTab == 1,
                                action: { selectedTab = 1 }
                            )

                            TabButton(
                                title: "Career",
                                isSelected: selectedTab == 2,
                                action: { selectedTab = 2 }
                            )

                            TabButton(
                                title: "Tributes",
                                isSelected: selectedTab == 3,
                                action: { selectedTab = 3 }
                            )
                        }
                        .background(Color(.systemGray6))

                        // Content
                        TabView(selection: $selectedTab) {
                            DetailsTabView(celebrity: celebrity)
                                .tag(0)

                            MediaTabView(celebrity: celebrity)
                                .tag(1)

                            CareerTabView(celebrity: celebrity)
                                .tag(2)

                            CelebrityTributesView(
                                tributes: socialViewModel.fetchTributesForCelebrity(celebrity.name),
                                socialViewModel: socialViewModel
                            )
                            .tag(3)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(minHeight: 400)
                    }
                }
            }
            .padding()
            .navigationTitle(celebrity.name.isEmpty ? "Celebrity Details" : celebrity.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCreateTribute) {
                CreateTributeView(socialViewModel: socialViewModel)
            }
        }
    }
}

struct CelebrityTributesView: View {
        let tributes: [Tribute]
        let socialViewModel: SocialViewModel

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if tributes.isEmpty {
                        EmptyStateView(
                            icon: "heart.fill",
                            title: "No Tributes Yet",
                            message: "Be the first to create a tribute for this celebrity"
                        )
                    } else {
                        ForEach(tributes, id: \.id) { tribute in
                            TributeCardView(
                                tribute: tribute,
                                viewModel: socialViewModel
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }

    struct DetailsTabView: View {
        let celebrity: Celebrity

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                // Interests Section
                if !celebrity.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests & Hobbies")
                            .font(.headline)
                            .fontWeight(.semibold)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 8) {
                            ForEach(celebrity.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Age", value: "\(celebrity.age)")

                    if let birthDate = celebrity.birthDate {
                        DetailRow(title: "Birth Date", value: birthDate)
                    }

                    if celebrity.isDeceased, let deathDate = celebrity.deathDate {
                        DetailRow(title: "Death Date", value: deathDate)
                    }

                    if let causeOfDeath = celebrity.causeOfDeath {
                        DetailRow(title: "Cause of Death", value: causeOfDeath)
                    }

                    if let nationality = celebrity.nationality {
                        DetailRow(title: "Nationality", value: nationality)
                    }

                    if let netWorth = celebrity.netWorth {
                        DetailRow(title: "Net Worth", value: netWorth)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    struct DetailRow: View {
        let title: String
        let value: String

        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.body)
            }
        }
    }

    // MARK: - Media Tab View
    struct MediaTabView: View {
        let celebrity: Celebrity
        @State private var selectedMediaType: MediaType = .photo

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Media Type Picker
                    Picker("Media Type", selection: $selectedMediaType) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue.capitalized)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Photo Gallery
                    if selectedMediaType == .photo {
                        PhotoGalleryView(celebrity: celebrity)
                    }

                    // Video Clips
                    if selectedMediaType == .video {
                        VideoGalleryView(celebrity: celebrity)
                    }

                    // Audio Clips
                    if selectedMediaType == .audio {
                        AudioGalleryView(celebrity: celebrity)
                    }
                }
            }
        }
    }

    struct PhotoGalleryView: View {
        let celebrity: Celebrity
        @State private var selectedPhotoIndex: Int?

        // Sample photo data - in real app, this would come from the database
        private var samplePhotos: [String] {
            [
                "https://example.com/photo1.jpg",
                "https://example.com/photo2.jpg",
                "https://example.com/photo3.jpg"
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Photo Gallery")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(samplePhotos.enumerated()), id: \.offset) { index, photoURL in
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedPhotoIndex = index
                                }
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 120)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .sheet(item: Binding(
                get: { selectedPhotoIndex.map { PhotoItem(url: samplePhotos[$0], index: $0) } },
                set: { _ in selectedPhotoIndex = nil }
            )) { photoItem in
                PhotoDetailView(photoURL: photoItem.url, index: photoItem.index, totalPhotos: samplePhotos.count)
            }
        }
    }

    struct VideoGalleryView: View {
        let celebrity: Celebrity

        // Sample video data
        private var sampleVideos: [VideoItem] {
            [
                VideoItem(title: "Memorable Interview", description: "Classic interview from 2010", duration: "5:23", thumbnailURL: "https://example.com/thumb1.jpg", videoURL: "https://example.com/video1.mp4"),
                VideoItem(title: "Award Acceptance", description: "Oscar acceptance speech", duration: "3:45", thumbnailURL: "https://example.com/thumb2.jpg", videoURL: "https://example.com/video2.mp4"),
                VideoItem(title: "Behind the Scenes", description: "Making of famous movie", duration: "8:12", thumbnailURL: "https://example.com/thumb3.jpg", videoURL: "https://example.com/video3.mp4")
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Video Clips")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVStack(spacing: 16) {
                    ForEach(sampleVideos, id: \.id) { video in
                        VideoCardView(video: video)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    struct AudioGalleryView: View {
        let celebrity: Celebrity

        // Sample audio data
        private var sampleAudio: [AudioItem] {
            [
                AudioItem(title: "Famous Speech", description: "Iconic speech from 1995", duration: "4:32", audioURL: "https://example.com/audio1.mp3"),
                AudioItem(title: "Radio Interview", description: "Deep conversation about life", duration: "12:45", audioURL: "https://example.com/audio2.mp3"),
                AudioItem(title: "Podcast Appearance", description: "Guest appearance on popular podcast", duration: "28:15", audioURL: "https://example.com/audio3.mp3")
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Audio Clips")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVStack(spacing: 16) {
                    ForEach(sampleAudio, id: \.id) { audio in
                        AudioCardView(audio: audio)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Career Tab View
    struct CareerTabView: View {
        let celebrity: Celebrity
        @State private var selectedSection = 0

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Section Picker
                    Picker("Section", selection: $selectedSection) {
                        Text("Timeline").tag(0)
                        Text("Highlights").tag(1)
                        Text("Quotes").tag(2)
                        Text("Biography").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    if selectedSection == 0 {
                        CareerTimelineView(celebrity: celebrity)
                    } else if selectedSection == 1 {
                        CareerHighlightsView(celebrity: celebrity)
                    } else if selectedSection == 2 {
                        QuotesView(celebrity: celebrity)
                    } else {
                        BiographyView(celebrity: celebrity)
                    }
                }
            }
        }
    }

    struct CareerTimelineView: View {
        let celebrity: Celebrity

        // Sample timeline data
        private var timelineEvents: [CelebrityTimelineEvent] {
            [
                CelebrityTimelineEvent(year: 1980, title: "Career Begins", description: "First major role in television", category: .breakthrough),
                CelebrityTimelineEvent(year: 1985, title: "Breakthrough Role", description: "Starred in critically acclaimed film", category: .breakthrough),
                CelebrityTimelineEvent(year: 1990, title: "First Award", description: "Won prestigious industry award", category: .award),
                CelebrityTimelineEvent(year: 1995, title: "Collaboration", description: "Worked with renowned director", category: .collaboration),
                CelebrityTimelineEvent(year: 2000, title: "Innovation", description: "Pioneered new acting technique", category: .innovation),
                CelebrityTimelineEvent(year: 2010, title: "Comeback", description: "Returned to prominence after hiatus", category: .comeback)
            ].sorted { $0.year < $1.year }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Career Timeline")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVStack(spacing: 20) {
                    ForEach(timelineEvents, id: \.id) { event in
                        TimelineEventView(event: event)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    struct CareerHighlightsView: View {
        let celebrity: Celebrity

        // Sample highlights data
        private var highlights: [CareerHighlight] {
            [
                CareerHighlight(celebrityId: celebrity.id, title: "Oscar Win", highlightDescription: "Best Actor for iconic role", year: 1995, category: .award, significance: "First Oscar win", imageURL: "https://example.com/oscar.jpg"),
                CareerHighlight(celebrityId: celebrity.id, title: "Box Office Success", highlightDescription: "Film grossed over $500M worldwide", year: 2000, category: .breakthrough, significance: "Highest grossing film", imageURL: "https://example.com/success.jpg"),
                CareerHighlight(celebrityId: celebrity.id, title: "Directorial Debut", highlightDescription: "First film as director", year: 2005, category: .innovation, significance: "Expanded creative control", imageURL: "https://example.com/director.jpg")
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Career Highlights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVStack(spacing: 16) {
                    ForEach(highlights, id: \.id) { highlight in
                        CareerHighlightCardView(highlight: highlight)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    struct QuotesView: View {
        let celebrity: Celebrity

        // Sample quotes data
        private var quotes: [CelebrityQuote] {
            [
                CelebrityQuote(celebrityId: celebrity.id, quoteText: "Life is what happens while you're busy making other plans.", context: "Interview with Rolling Stone", source: "Rolling Stone Magazine", year: 1995, isVerified: true),
                CelebrityQuote(celebrityId: celebrity.id, quoteText: "The only way to do great work is to love what you do.", context: "Commencement speech", source: "Stanford University", year: 2005, isVerified: true),
                CelebrityQuote(celebrityId: celebrity.id, quoteText: "Success is not final, failure is not fatal: it is the courage to continue that counts.", context: "Award acceptance speech", source: "Academy Awards", year: 2010, isVerified: true)
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Memorable Quotes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                LazyVStack(spacing: 16) {
                    ForEach(quotes, id: \.id) { quote in
                        QuoteCardView(quote: quote)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    struct BiographyView: View {
        let celebrity: Celebrity

        // Sample biography data
        private var biography: CelebrityBiography {
            CelebrityBiography(
                celebrityId: celebrity.id,
                earlyLife: "Born in a small town, showed early talent in performing arts. Attended prestigious acting school and began career in theater.",
                career: "Rising through the ranks of Hollywood, became one of the most respected actors of their generation. Known for versatility and dedication to craft.",
                personalLife: "Married twice, has three children. Known for philanthropy and environmental activism.",
                legacy: "Left indelible mark on cinema and inspired generations of actors. Known for pushing boundaries and taking risks.",
                achievements: "Multiple awards including Oscars, Golden Globes, and lifetime achievement honors."
            )
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Biography")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    BiographySection(title: "Early Life", content: biography.earlyLife)
                    BiographySection(title: "Career", content: biography.career)
                    if let personalLife = biography.personalLife {
                        BiographySection(title: "Personal Life", content: personalLife)
                    }
                    if let legacy = biography.legacy {
                        BiographySection(title: "Legacy", content: legacy)
                    }
                    if let achievements = biography.achievements {
                        BiographySection(title: "Achievements", content: achievements)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Supporting Views
    struct PhotoItem: Identifiable {
        let id = UUID()
        let url: String
        let index: Int
    }

    struct VideoItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let duration: String
        let thumbnailURL: String
        let videoURL: String
    }

    struct AudioItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let duration: String
        let audioURL: String
    }

    struct CelebrityTimelineEvent: Identifiable {
        let id = UUID()
        let year: Int
        let title: String
        let description: String
        let category: CareerCategory
    }

    struct PhotoDetailView: View {
        let photoURL: String
        let index: Int
        let totalPhotos: Int
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationView {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .navigationTitle("Photo \(index + 1) of \(totalPhotos)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    struct VideoCardView: View {
        let video: VideoItem

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.headline)
                        .fontWeight(.medium)

                    Text(video.description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text(video.duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    struct AudioCardView: View {
        let audio: AudioItem

        var body: some View {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "waveform")
                            .foregroundColor(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(audio.title)
                        .font(.headline)
                        .fontWeight(.medium)

                    Text(audio.description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(audio.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    // Play audio
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    struct TimelineEventView: View {
        let event: CelebrityTimelineEvent

        var body: some View {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(event.year)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(event.category.color))

                    Circle()
                        .fill(Color(event.category.color))
                        .frame(width: 8, height: 8)

                    Spacer()
                }
                .frame(width: 60)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: event.category.icon)
                            .foregroundColor(Color(event.category.color))
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.medium)
                    }

                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    struct CareerHighlightCardView: View {
        let highlight: CareerHighlight

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: highlight.category.icon)
                        .foregroundColor(Color(highlight.category.color))
                    Text(highlight.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(highlight.year)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(highlight.highlightDescription)
                    .font(.body)
                    .foregroundColor(.secondary)

                if let significance = highlight.significance {
                    Text(significance)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(highlight.category.color).opacity(0.2))
                        .foregroundColor(Color(highlight.category.color))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    struct QuoteCardView: View {
        let quote: CelebrityQuote

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("\"\(quote.quoteText)\"")
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.leading)

                if let context = quote.context {
                    Text("— \(context)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    if let source = quote.source {
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let year = quote.year {
                        Text("(\(year))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if quote.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    struct BiographySection: View {
        let title: String
        let content: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
