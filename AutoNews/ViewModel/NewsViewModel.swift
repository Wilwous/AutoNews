//
//  NewsViewModel.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import Foundation
import Combine

final class NewsViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var newsList: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var currentPage = 1
    private let pageSize = 15
    
    // MARK: - Public Methods
    
    func loadNews() {
        isLoading = true
        Task {
            do {
                let newsResponse = try await NetworkService.shared.fetchNews(page: currentPage, pageSize: pageSize)
                DispatchQueue.main.async {
                    self.newsList = newsResponse.news
                    self.isLoading = false
                }
            } catch {
                self.isLoading = false
                self.errorMessage = "Не удалось загрузить новости. Попробуйте позже."
            }
        }
    }
    
    func loadMoreNews() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        Task {
            do {
                let newsResponse = try await NetworkService.shared.fetchNews(page: currentPage, pageSize: pageSize)
                DispatchQueue.main.async {
                    self.newsList.append(contentsOf: newsResponse.news)
                    self.isLoading = false
                }
            } catch {
                print("Failed to load more news: \(error)")
                self.isLoading = false
            }
        }
    }
}
