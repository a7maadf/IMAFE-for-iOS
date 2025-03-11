//
//  checkImageEncryptionStatus.swift
//  IMAFE
//
//  Created by Ahmad Salem on 3/11/25.
//

import Foundation

func checkEncryption(image: Data) -> Bool? {
       
    let startMarker = "\n---encryption start here---\n"
    
    // Convert markers to Data
    guard let startMarkerData = startMarker.data(using: .utf8) else {
        print("Error: Could not convert markers to Data.")
        return false
    }
    
    // Check if the marker exists in the image data
    if image.range(of: startMarkerData) != nil {
        return true
    } else {
        return false
    }
}

