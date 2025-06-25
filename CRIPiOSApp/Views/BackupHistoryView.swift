//
//  BackupHistoryView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import SwiftUI

struct BackupHistoryView: View {
    let cloudBackupService: CloudBackupService
    @Binding var socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var backupDates: [Date] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading backup history...")
                } else if backupDates.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No backups found")
                            .font(.headline)
                        Text("Your first backup will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(backupDates, id: \.self) { date in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Backup")
                                        .font(.headline)
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(date.formatted(.relative(presentation: .named)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Backup History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadBackupHistory()
        }
    }
    
    private func loadBackupHistory() async {
        guard let currentUser = socialViewModel.currentUser else { return }
        
        let dates = await cloudBackupService.getBackupHistory(userId: currentUser.id.uuidString)
        
        await MainActor.run {
            backupDates = dates
            isLoading = false
        }
    }
} 