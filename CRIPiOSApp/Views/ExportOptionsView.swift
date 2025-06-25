//
//  ExportOptionsView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import SwiftUI

struct ExportOptionsView: View {
    let exportService: ExportService
    @Binding var selectedFormat: ExportService.ExportFormat
    @Binding var isExporting: Bool
    @Binding var exportFileURL: URL?
    @Binding var showingShareSheet: Bool
    @Binding var viewModel: CelebrityViewModel
    @Binding var socialViewModel: SocialViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Export Options")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Format")
                        .font(.headline)
                    
                    ForEach(ExportService.ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Button(action: {
                                selectedFormat = format
                            }) {
                                HStack {
                                    Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedFormat == format ? .accentColor : .secondary)
                                    
                                    VStack(alignment: .leading) {
                                        Text(format.rawValue)
                                            .fontWeight(.medium)
                                        Text("\(format.fileExtension.uppercased()) format")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    Button("Export Celebrity List") {
                        exportCelebrityList()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                    
                    if let currentUser = socialViewModel.currentUser {
                        Button("Export User Data") {
                            exportUserData(user: currentUser)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    }
                }
                
                if isExporting {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Exporting...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportCelebrityList() {
        isExporting = true
        
        Task {
            let celebrities = viewModel.fetchCelebrities()
            let fileURL = await exportService.exportCelebrityList(celebrities, format: selectedFormat)
            
            await MainActor.run {
                isExporting = false
                if let fileURL = fileURL {
                    exportFileURL = fileURL
                    showingShareSheet = true
                    dismiss()
                }
            }
        }
    }
    
    private func exportUserData(user: UserProfile) {
        isExporting = true
        
        Task {
            let celebrities = viewModel.fetchCelebrities()
            let tributes = socialViewModel.fetchTributes()
            let watchlist = socialViewModel.fetchWatchlistItems()
            
            let fileURL = await exportService.exportUserData(
                userProfile: user,
                celebrities: celebrities,
                tributes: tributes,
                watchlist: watchlist,
                format: selectedFormat
            )
            
            await MainActor.run {
                isExporting = false
                if let fileURL = fileURL {
                    exportFileURL = fileURL
                    showingShareSheet = true
                    dismiss()
                }
            }
        }
    }
} 
