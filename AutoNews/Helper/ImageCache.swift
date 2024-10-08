//
//  ImageCache.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import UIKit

final class ImageCache {
    
    // MARK: - Static
    
    static let shared = NSCache<NSString, UIImage>()
}
