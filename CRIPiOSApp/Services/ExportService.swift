//
//  ExportService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-01-27.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@Observable
class ExportService {
    static let shared = ExportService()
    
    var isExporting = false
    var exportProgress: Double = 0.0
    var exportStatus: String = ""
    
    private init() {}
    
    // MARK: - Export Formats
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case pdf = "PDF"
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            case .pdf: return "pdf"
            }
        }
        
        var mimeType: String {
            switch self {
            case .json: return "application/json"
            case .csv: return "text/csv"
            case .pdf: return "application/pdf"
            }
        }
    }
    
    // MARK: - Export Data
    
    func exportCelebrityList(_ celebrities: [Celebrity], format: ExportFormat) async -> URL? {
        isExporting = true
        exportProgress = 0.0
        exportStatus = "Preparing export..."
        
        defer {
            isExporting = false
            exportProgress = 0.0
            exportStatus = ""
        }
        
        exportProgress = 0.2
        exportStatus = "Processing data..."
        
        let exportData = await prepareCelebrityData(celebrities)
        
        exportProgress = 0.5
        exportStatus = "Generating file..."
        
        guard let fileURL = await generateExportFile(data: exportData, format: format, filename: "celebrity_list") else {
            exportStatus = "Export failed"
            return nil
        }
        
        exportProgress = 1.0
        exportStatus = "Export completed"
        
        return fileURL
    }
    
    func exportUserData(userProfile: UserProfile, celebrities: [Celebrity], tributes: [Tribute], watchlist: [WatchlistItem], format: ExportFormat) async -> URL? {
        isExporting = true
        exportProgress = 0.0
        exportStatus = "Preparing user data export..."
        
        defer {
            isExporting = false
            exportProgress = 0.0
            exportStatus = ""
        }
        
        exportProgress = 0.2
        exportStatus = "Processing user data..."
        
        let userData = await prepareUserData(userProfile: userProfile, celebrities: celebrities, tributes: tributes, watchlist: watchlist)
        
        exportProgress = 0.5
        exportStatus = "Generating file..."
        
        guard let fileURL = await generateExportFile(data: userData, format: format, filename: "user_data_\(userProfile.username)") else {
            exportStatus = "Export failed"
            return nil
        }
        
        exportProgress = 1.0
        exportStatus = "Export completed"
        
        return fileURL
    }
    
    // MARK: - Data Preparation
    
    private func prepareCelebrityData(_ celebrities: [Celebrity]) async -> [String: Any] {
        let celebrityData = celebrities.map { celebrity in
            [
                "id": celebrity.id.uuidString,
                "name": celebrity.name,
                "occupation": celebrity.occupation,
                "age": celebrity.age,
                "isDeceased": celebrity.isDeceased,
                "birthDate": celebrity.birthDate ?? "",
                "deathDate": celebrity.deathDate ?? "",
                "causeOfDeath": celebrity.causeOfDeath ?? "",
                "nationality": celebrity.nationality ?? "",
                "netWorth": celebrity.netWorth ?? "",
                "interests": celebrity.interests,
                "isFeatured": celebrity.isFeatured,
                "lastUpdated": ISO8601DateFormatter().string(from: celebrity.lastUpdated)
            ]
        }
        
        return [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalCelebrities": celebrities.count,
            "livingCelebrities": celebrities.filter { !$0.isDeceased }.count,
            "deceasedCelebrities": celebrities.filter { $0.isDeceased }.count,
            "celebrities": celebrityData
        ]
    }
    
    private func prepareUserData(userProfile: UserProfile, celebrities: [Celebrity], tributes: [Tribute], watchlist: [WatchlistItem]) async -> [String: Any] {
        let userTributes = tributes.filter { $0.authorId == userProfile.id }
        let userWatchlist = watchlist.filter { $0.userId == userProfile.id }
        
        let tributeData = userTributes.map { tribute in
            [
                "id": tribute.id.uuidString,
                "celebrityName": tribute.celebrityName,
                "title": tribute.title,
                "content": tribute.content,
                "tags": tribute.tags,
                "likeCount": tribute.likeCount,
                "commentCount": tribute.commentCount,
                "createdAt": ISO8601DateFormatter().string(from: tribute.createdAt)
            ]
        }
        
        let watchlistData = userWatchlist.map { item in
            [
                "celebrityName": item.celebrityName,
                "notes": item.notes ?? "",
                "priority": item.priority.rawValue,
                "addedDate": ISO8601DateFormatter().string(from: item.addedDate)
            ]
        }
        
        return [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "userProfile": [
                "username": userProfile.username,
                "displayName": userProfile.displayName,
                "bio": userProfile.bio ?? "",
                "joinDate": ISO8601DateFormatter().string(from: userProfile.joinDate),
                "interests": userProfile.interests,
                "favoriteCelebrities": userProfile.favoriteCelebrities,
                "followerCount": userProfile.followerCount,
                "followingCount": userProfile.followingCount,
                "tributeCount": userProfile.tributeCount,
                "discussionCount": userProfile.discussionCount
            ],
            "statistics": [
                "totalTributes": userTributes.count,
                "totalWatchlistItems": userWatchlist.count,
                "favoriteCelebritiesCount": userProfile.favoriteCelebrities.count
            ],
            "tributes": tributeData,
            "watchlist": watchlistData
        ]
    }
    
    // MARK: - File Generation
    
    private func generateExportFile(data: [String: Any], format: ExportFormat, filename: String) async -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(filename)_\(Date().timeIntervalSince1970).\(format.fileExtension)"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            switch format {
            case .json:
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys])
                try jsonData.write(to: fileURL)
                
            case .csv:
                let csvString = convertToCSV(data: data)
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                
            case .pdf:
                let pdfData = generatePDF(data: data)
                try pdfData.write(to: fileURL)
            }
            
            return fileURL
        } catch {
            print("❌ Failed to generate export file: \(error)")
            return nil
        }
    }
    
    // MARK: - Format Converters
    
    private func convertToCSV(data: [String: Any]) -> String {
        var csvLines: [String] = []
        
        // Add header
        if let celebrities = data["celebrities"] as? [[String: Any]] {
            if !celebrities.isEmpty {
                let headers = celebrities[0].keys.sorted()
                csvLines.append(headers.joined(separator: ","))
                
                // Add data rows
                for celebrity in celebrities {
                    let values = headers.map { header in
                        let value = celebrity[header] ?? ""
                        if let array = value as? [String] {
                            return "\"\(array.joined(separator: "; "))\""
                        } else {
                            return "\"\(value)\""
                        }
                    }
                    csvLines.append(values.joined(separator: ","))
                }
            }
        }
        
        return csvLines.joined(separator: "\n")
    }
    
    private func generatePDF(data: [String: Any]) -> Data {
        // Simple PDF generation - in a real app, you might use a library like PDFKit
        let pdfString = """
        CRIP iOS App - Data Export
        Generated: \(data["exportDate"] as? String ?? "")
        
        """
        
        // Convert to PDF data (simplified)
        return pdfString.data(using: .utf8) ?? Data()
    }
    
    // MARK: - Share Sheet
    
    func shareFile(_ fileURL: URL) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // Exclude some activity types that might not work well with our data
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        return activityViewController
    }
    
    // MARK: - Cleanup
    
    func cleanupExportFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            let exportFiles = files.filter { $0.lastPathComponent.contains("celebrity_list_") || $0.lastPathComponent.contains("user_data_") }
            
            for file in exportFiles {
                try FileManager.default.removeItem(at: file)
            }
            
            print("✅ Cleaned up \(exportFiles.count) export files")
        } catch {
            print("❌ Failed to cleanup export files: \(error)")
        }
    }
} 