//
//  NetworkService.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    // Fetch Wikipedia image URL for a celebrity
    func fetchWikipediaImageURL(for name: String) async -> String? {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&titles=\(encodedName)&prop=pageimages&format=json&pithumbsize=400"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let query = json["query"] as? [String: Any],
               let pages = query["pages"] as? [String: Any],
               let page = pages.values.first as? [String: Any],
               let thumbnail = page["thumbnail"] as? [String: Any],
               let source = thumbnail["source"] as? String {
                return source
            }
        } catch {
            print("❌ Network error fetching Wikipedia image for \(name): \(error)")
        }
        return nil
    }
    
    // Fetch Wikidata death date for a celebrity
    func fetchDeathDateFromWikipedia(for name: String) async -> String? {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&titles=\(encodedName)&prop=pageprops&format=json"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let query = json["query"] as? [String: Any],
               let pages = query["pages"] as? [String: Any],
               let page = pages.values.first as? [String: Any],
               let pageprops = page["pageprops"] as? [String: Any],
               let wikibase_item = pageprops["wikibase_item"] as? String {
                // Now query Wikidata for the death date
                return await fetchDeathDateFromWikidata(for: wikibase_item)
            }
        } catch {
            print("❌ Network error fetching Wikipedia data for \(name): \(error)")
        }
        return nil
    }
    
    private func fetchDeathDateFromWikidata(for wikibaseItem: String) async -> String? {
        let urlString = "https://www.wikidata.org/wiki/Special:EntityData/\(wikibaseItem).json"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let entities = json["entities"] as? [String: Any],
               let entity = entities[wikibaseItem] as? [String: Any],
               let claims = entity["claims"] as? [String: Any],
               let deathClaim = claims["P570"] as? [[String: Any]],
               let mainsnak = deathClaim.first?["mainsnak"] as? [String: Any],
               let datavalue = mainsnak["datavalue"] as? [String: Any],
               let value = datavalue["value"] as? [String: Any],
               let time = value["time"] as? String {
                // Wikidata time format: "+YYYY-MM-DDT00:00:00Z"
                let date = time.trimmingCharacters(in: CharacterSet(charactersIn: "+T00:00:00Z"))
                return date
            }
        } catch {
            print("❌ Network error fetching Wikidata data for \(wikibaseItem): \(error)")
        }
        return nil
    }
} 