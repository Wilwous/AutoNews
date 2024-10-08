//
//  DateFormatterHelper.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import Foundation

struct DateFormatterHelper {
    
    // MARK: - Static
    
    static func formatDate(from dateString: String) -> String {
        let trimmedDateString = dateString.components(separatedBy: "T").first ?? dateString
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        
        if let date = isoFormatter.date(from: trimmedDateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "d MMMM yyyy"
            displayFormatter.locale = Locale(identifier: "ru_RU")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
