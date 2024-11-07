//
//  APICard.swift
//  romantic-self
//
//  Created by 岳一扬 on 2024/9/22.
//


import Foundation

struct APICard: Codable, Identifiable {
    let card_id: Int
    let content: String
    let created_at: String
    let audio_url: String?
    let background_music_url: String?
    let mood: String
    let is_discussion_card: Bool
    let tags: [String]
    
    var id: Int { card_id }
}

struct APIResponse: Codable {
    let cards: [APICard]
    let total: Int
    let pages: Int
    let current_page: Int
}

class CardAPIService: ObservableObject {
    @Published var cards: [APICard] = []
    private let baseURL = "<替换为您的API域名>" 
    
    func fetchCards() {
        guard let url = URL(string: "\(baseURL)/cards") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(APIResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.cards = decodedResponse.cards
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func searchCards(query: String) {
        guard let url = URL(string: "\(baseURL)/cards/search?q=\(query)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(APIResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.cards = decodedResponse.cards
                    }
                    return
                }
            }
            print("Search failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
