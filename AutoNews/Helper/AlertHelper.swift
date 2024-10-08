//
//  AlertHelper.swift
//  AutoNews
//
//  Created by Антон Павлов on 08.10.2024.
//

import UIKit

// MARK: - Alert

final class AlertHelper {
    
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
