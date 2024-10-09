//
//  NetworkService.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import Foundation

// MARK: - Network

actor NetworkService {
    
    // MARK: - Static
    
    static let shared = NetworkService()
    
    // MARK: - Constants
    
    private let baseURL = "https://webapi.autodoc.ru/api/news"
    
    // MARK: - Public Methods
    
    func fetchNews(page: Int, pageSize: Int) async throws -> NewsResponse {
        let urlString = "\(baseURL)/\(page)/\(pageSize)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let newsResponse = try decoder.decode(NewsResponse.self, from: data)
        return newsResponse
    }
}
