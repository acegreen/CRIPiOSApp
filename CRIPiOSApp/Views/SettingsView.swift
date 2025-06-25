//
//  SettingsView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Binding var settingsViewModel: SettingsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    private let cronService = CronService.shared
    private let exportService = ExportService.shared
    //    private let cloudBackupService = CloudBackupService.shared

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("cronFrequency") private var cronFrequency: CronFrequency = .daily

    @State private var showingInterestsSettings = false
    @State private var showingLoginView = false
    @State private var showingUserProfile = false
    @State private var showingExportSheet = false
    @State private var showingShareSheet = false
    @State private var showingBackupHistory = false
    @State private var isPerformingDeathCheck = false
    @State private var lastDeathCheckDate: Date = Date.distantPast
    @State private var selectedExportFormat: ExportService.ExportFormat = .json
    @State private var exportFileURL: URL?
    @State private var isExporting = false

    init(settingsViewModel: Binding<SettingsViewModel>,
         celebrityViewModel: Binding<CelebrityViewModel>,
         socialViewModel: Binding<SocialViewModel>) {
        self._settingsViewModel = settingsViewModel
        self._celebrityViewModel = celebrityViewModel
        self._socialViewModel = socialViewModel
    }

    var body: some View {
        NavigationView {
            List {
                accountSection
                if socialViewModel.isLoggedIn {
                    personalizationSection
                }
                backgroundDeathChecksSection
                notificationsSection
                appearanceSection
                dataAndBackupSection

#if DEBUG
                testingSection
#endif

                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingInterestsSettings) {
                InterestsSettingsView(viewModel: $celebrityViewModel)
            }
            .sheet(isPresented: $showingLoginView) {
                LoginView(socialViewModel: $socialViewModel)
            }
            .sheet(isPresented: $showingUserProfile) {
                if let currentUser = socialViewModel.currentUser {
                    NavigationView {
                        UserProfileView(socialViewModel: $socialViewModel, user: currentUser)
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportOptionsView(
                    exportService: exportService,
                    selectedFormat: $selectedExportFormat,
                    isExporting: $isExporting,
                    exportFileURL: $exportFileURL,
                    showingShareSheet: $showingShareSheet,
                    viewModel: $celebrityViewModel,
                    socialViewModel: $socialViewModel
                )
            }
            //            .sheet(isPresented: $showingBackupHistory) {
            //                BackupHistoryView(cloudBackupService: cloudBackupService, socialViewModel: $socialViewModel)
            //            }
            .sheet(isPresented: $showingShareSheet) {
                if let fileURL = exportFileURL {
                    ShareSheet(activityItems: [fileURL])
                }
            }
        }
    }

    // MARK: - View Sections

    private var accountSection: some View {
        Section("Account") {
            if let currentUser = socialViewModel.currentUser {
                HStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(String(currentUser.displayName.prefix(1)))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentUser.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("@\(currentUser.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("View") {
                        showingUserProfile = true
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }

                Button("Sign Out") {
                    socialViewModel.logoutUser()
                    celebrityViewModel.clearUserInterests()
                }
                .foregroundColor(.red)
            } else {
                Button("Sign In / Create Account") {
                    showingLoginView = true
                }
                .foregroundColor(.accentColor)
            }
        }
    }

    private var personalizationSection: some View {
        Section("Personalization") {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interests & Hobbies")
                        .font(.body)

                    if celebrityViewModel.userInterests.selectedInterests.isEmpty {
                        Text("No interests selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(celebrityViewModel.userInterests.selectedInterests.count) interests selected")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }

                Spacer()

                Button("Manage") {
                    showingInterestsSettings = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }

    private var backgroundDeathChecksSection: some View {
        Section("Background Death Checks") {
            Picker("Check Frequency", selection: $cronFrequency) {
                ForEach(CronFrequency.allCases, id: \.self) { frequency in
                    Text(frequency.displayName)
                        .tag(frequency)
                }
            }
            .onChange(of: cronFrequency) { newValue in
                settingsViewModel.updateCronFrequency(newValue)
            }

            HStack {
                Text("Last Check")
                Spacer()
                Text(settingsViewModel.lastDeathCheckDate == Date.distantPast ? "Never" : settingsViewModel.lastDeathCheckDate.formatted(.relative(presentation: .named)))
                    .foregroundColor(.secondary)
            }

            Button(action: {
                Task {
                    await settingsViewModel.performManualDeathCheck()
                }
            }) {
                HStack {
                    if settingsViewModel.isPerformingDeathCheck {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text("Check for Deaths Now")
                }
            }
            .disabled(settingsViewModel.isPerformingDeathCheck)
        }
    }

    private var dataAndBackupSection: some View {
        Section("Data & Backup") {
            // Cloud Backup Status
            //            HStack {
            //                VStack(alignment: .leading, spacing: 4) {
            //                    Text("iCloud Backup")
            //                        .font(.headline)
            //                    Text("Backup your preferences and data")
            //                        .font(.caption)
            //                        .foregroundColor(.secondary)
            //                }
            //
            //                Spacer()
            //
            //                if cloudBackupService.isCloudAvailable {
            //                    Image(systemName: "checkmark.circle.fill")
            //                        .foregroundColor(.green)
            //                } else {
            //                    Image(systemName: "xmark.circle.fill")
            //                        .foregroundColor(.red)
            //                }
            //            }
            //
            //            if let lastBackup = cloudBackupService.lastBackupDate {
            //                HStack {
            //                    Text("Last Backup")
            //                    Spacer()
            //                    Text(lastBackup.formatted(.relative(presentation: .named)))
            //                        .foregroundColor(.secondary)
            //                }
            //            }
            //
            //            if cloudBackupService.isCloudAvailable {
            //                Button("Backup Now") {
            //                    performBackup()
            //                }
            //                .foregroundColor(.accentColor)
            //
            //                Button("Restore from Backup") {
            //                    performRestore()
            //                }
            //                .foregroundColor(.accentColor)
            //
            //                Button("Backup History") {
            //                    showingBackupHistory = true
            //                }
            //                .foregroundColor(.accentColor)
            //            }
            //
            //            if cloudBackupService.isBackingUp || cloudBackupService.isRestoring {
            //                VStack(alignment: .leading, spacing: 8) {
            //                    HStack {
            //                        ProgressView()
            //                            .scaleEffect(0.8)
            //                        Text(cloudBackupService.backupStatus)
            //                            .font(.caption)
            //                    }
            //
            //                    ProgressView(value: cloudBackupService.backupProgress)
            //                        .progressViewStyle(LinearProgressViewStyle())
            //                }
            //                .padding(.vertical, 4)
            //            }

            Divider()

            // Data Export
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Data")
                        .font(.headline)
                    Text("Download your celebrity lists and user data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("Export") {
                    showingExportSheet = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            if isExporting {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(exportService.exportStatus)
                            .font(.caption)
                    }

                    ProgressView(value: exportService.exportProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
            Toggle("Death Alerts", isOn: $notificationsEnabled)
            Toggle("Social Notifications", isOn: $notificationsEnabled)
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Toggle("Dark Mode", isOn: $darkModeEnabled)
        }
    }

#if DEBUG
    private var testingSection: some View {
        Section("Testing") {
            VStack(alignment: .leading, spacing: 12) {

                Button(action: {
                    testSophiaLeoneDeath()
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        Text("Test Sophia Leone Death Detection")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.orange)

                Button(action: {
                    testFullDeathCheckProcess()
                }) {
                    HStack {
                        Image(systemName: "play.circle")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Test Full Death Check Process")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)

                Button(action: {
                    testInAppAlert()
                }) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        Text("Test In-App Death Alert")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.green)

                Button(action: {
                    testBackgroundDeathAlert()
                }) {
                    HStack {
                        Image(systemName: "bell.and.waves.left.and.right")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        Text("Test Background Death Alert")
                            .font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.purple)

                // Restore All Data button below the tests
                Button(action: {
                    celebrityViewModel.clearAndReloadData()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restore All Data")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.red)
                .padding(.top, 12)
            }
            .padding(.vertical, 4)
        }
    }
#endif

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Button("Privacy Policy") {
                // Open privacy policy
            }

            Button("Terms of Service") {
                // Open terms of service
            }
        }
    }

    private func performManualDeathCheck() {
        isPerformingDeathCheck = true

        Task {
            await cronService.performManualDeathCheck()

            await MainActor.run {
                isPerformingDeathCheck = false
                lastDeathCheckDate = Date()
            }
        }
    }

    // MARK: - Cloud Backup

    //    private func performBackup() {
    //        guard let currentUser = viewModel.getSocialViewModel().currentUser else { return }
    //
    //        Task {
    //            let celebrities = viewModel.fetchCelebrities()
    //            let tributes = viewModel.getSocialViewModel().fetchTributes()
    //            let watchlist = viewModel.getSocialViewModel().fetchWatchlistItems()
    //
    //            let success = await cloudBackupService.backupUserData(
    //                userProfile: currentUser,
    //                userInterests: viewModel.userInterests,
    //                watchlist: watchlist,
    //                tributes: tributes
    //            )
    //        }
    //    }
    //
    //    private func performRestore() {
    //        guard let currentUser = viewModel.getSocialViewModel().currentUser else { return }
    //
    //        Task {
    //            let restoredData = await cloudBackupService.restoreUserData(userId: currentUser.id.uuidString)
    //
    //            await MainActor.run {
    //                if let (userProfile, userInterests, watchlist, tributes) = restoredData {
    //                    // Restore the data
    //                    if let userProfile = userProfile {
    //                        viewModel.getSocialViewModel().currentUser = userProfile
    //                    }
    //                    if let userInterests = userInterests {
    //                        viewModel.userInterests = userInterests
    //                        viewModel.saveUserInterests()
    //                    }
    //
    //                }
    //            }
    //        }
    //    }

#if DEBUG
    private func testSophiaLeoneDeath() {
        Task {
            do {
                print("🧪 Starting Sophia Leone death detection test...")

                let deathCheckService = DeathCheckService()
                let newDeaths = await deathCheckService.testSophiaLeoneDeathDetection()

                await MainActor.run {
                    if !newDeaths.isEmpty {
                        print("✅ Test completed: Sophia Leone death detected!")
                        print("📊 Results: \(newDeaths.count) death(s) detected")
                    } else {
                        print("❌ Test completed: No deaths detected")
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ Test failed with error: \(error)")
                }
            }
        }
    }

    private func testFullDeathCheckProcess() {
        Task {
            do {
                print("🧪 Starting full death check process test...")

                let deathCheckService = DeathCheckService()
                await deathCheckService.testFullDeathCheckProcess()

                await MainActor.run {
                    print("✅ Full death check process test completed!")
                }
            } catch {
                await MainActor.run {
                    print("❌ Full death check process test failed with error: \(error)")
                }
            }
        }
    }

    private func testInAppAlert() {
        print("🧪 Testing in-app death alert...")

        guard let sophia = celebrityViewModel.getSophiaLeoneFromDB() else {
            print("❌ Sophia Leone not found in database")
            return
        }

        let testCelebrities = [sophia]

        cronService.deathAlertCelebrities = testCelebrities
        cronService.showingDeathAlert = true

        print("✅ In-app death alert test triggered!")
    }

    private func testBackgroundDeathAlert() {
        print("🧪 Testing background death alert...")
        print("📱 Please background the app now - notification will be sent in 5 seconds...")

        guard let sophia = celebrityViewModel.getSophiaLeoneFromDB() else {
            print("❌ Sophia Leone not found in database")
            return
        }

        // Create test celebrity data
        let testCelebrities = [sophia]

        // Delay for 5 seconds to allow user to background the app
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

            await MainActor.run {
                // Update the view model with new deaths
                celebrityViewModel.updateCelebritiesFromDeathCheck(testCelebrities)
                celebrityViewModel.refreshCelebrities()

                // Create a notification for the death alert
                socialViewModel.createNotification(
                    type: .deathAlert,
                    title: "Death Alert",
                    message: "Sophia Leone has passed away. Our thoughts are with her family and friends.",
                    relatedId: testCelebrities.first?.id,
                    relatedType: "celebrity"
                )
            }

            // Send push notification (simulates background notification)
            await sendTestPushNotification(for: testCelebrities)

            print("✅ Background death alert test completed!")
            print("📊 Test celebrity: \(testCelebrities.first?.name ?? "Unknown")")
            print("🔔 Push notification should have been sent!")
        }
    }

    private func sendTestPushNotification(for celebrities: [Celebrity]) async {
        let content = UNMutableNotificationContent()
        content.title = "Celebrity Death Alert"
        content.body = "\(celebrities.first?.name ?? "A celebrity") has passed away"
        content.subtitle = celebrities.first?.occupation ?? "Celebrity"
        content.sound = .default
        content.badge = 1

        // Create and attach celebrity image
        if let celebrity = celebrities.first {
            await addCelebrityImageAttachment(to: content, celebrity: celebrity)
        }

        // Add custom data for the notification
        content.userInfo = [
            "type": "death_alert",
            "celebrity_id": celebrities.first?.id.uuidString ?? "",
            "celebrity_name": celebrities.first?.name ?? "",
            "celebrity_occupation": celebrities.first?.occupation ?? "",
            "death_date": celebrities.first?.deathDate ?? ""
        ]

        let request = UNNotificationRequest(
            identifier: "test-death-\(celebrities.first?.id.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: nil // Immediate delivery
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Test push notification sent successfully!")
            print("📱 Notification details:")
            print("   - Title: \(content.title)")
            print("   - Body: \(content.body)")
            print("   - Subtitle: \(content.subtitle)")
            print("   - Attachments: \(content.attachments.count)")
        } catch {
            print("❌ Failed to send test push notification: \(error)")
        }
    }

    private func addCelebrityImageAttachment(to content: UNMutableNotificationContent, celebrity: Celebrity) async {
        do {
            // Create a celebrity image with their initial
            let image = createCelebrityImage(for: celebrity)

            // Save the image to a temporary file
            let tempURL = try saveImageToTempFile(image, filename: "\(celebrity.name).jpg")

            // Create the attachment
            let attachment = try UNNotificationAttachment(
                identifier: "celebrity-image",
                url: tempURL,
                options: [UNNotificationAttachmentOptionsTypeHintKey: "public.jpeg"]
            )

            // Add the attachment to the notification
            content.attachments = [attachment]

            print("✅ Celebrity image attached to notification")

        } catch {
            print("❌ Failed to add celebrity image: \(error)")
        }
    }

    private func createCelebrityImage(for celebrity: Celebrity) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemRed.cgColor,
                    UIColor.systemPink.cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )!

            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )

            // Celebrity initial
            let initial = String(celebrity.name.prefix(1)).uppercased()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 120, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            let textSize = initial.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            initial.draw(in: textRect, withAttributes: attributes)
            
            // Add a subtle border
            context.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            context.cgContext.setLineWidth(4)
            context.cgContext.strokeEllipse(in: CGRect(x: 8, y: 8, width: size.width - 16, height: size.height - 16))
        }
    }

    private func saveImageToTempFile(_ image: UIImage, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }

        try imageData.write(to: fileURL)
        return fileURL
    }
#endif
}
