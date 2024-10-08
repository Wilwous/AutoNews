//
//  NewsItem.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import Foundation

struct NewsItem: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let fullUrl: String
    let titleImageUrl: String
    let categoryType: String
}
