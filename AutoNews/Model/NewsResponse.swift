//
//  NewsResponse.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import Foundation

struct NewsResponse: Decodable {
    let news: [NewsItem]
    let totalCount: Int
}
