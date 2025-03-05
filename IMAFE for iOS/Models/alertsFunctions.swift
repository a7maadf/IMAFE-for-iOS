//
//  alertsFunctions.swift
//  IMAFE for iOS
//
//  Created by Ahmad Salem on 3/5/25.
//

import Foundation
import UIKit



func showErrorAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    // Make sure this runs on a view controller
    if let topVC = UIApplication.shared.windows.first?.rootViewController {
        topVC.present(alert, animated: true, completion: nil)
    }
}
