//
//  encryptionFunction.swift
//  IMAFE for iOS
//
//  Created by Ahmad Salem on 3/4/25.
//

import CommonCrypto
import Foundation
import CryptoKit
import UIKit


func encryptImage(image: UIImage, text: String, password: String) -> Data? {
    let startMarker = "\n---added text start here---\n"
    let endMarker = "\n---added text end here---\n"
    
    // Convert UIImage to PNG Data
    guard let imageData = image.pngData() else {
        print("Error: Could not convert UIImage to Data.")
        return nil
    }

    // Encrypt only the text (not the marker)
    guard let encryptedTextData = encryptText(text: text, password: password) else {
        print("Error: Could not encrypt text.")
        return nil
    }

    // Convert start marker to Data
    guard let startMarkerData = startMarker.data(using: .utf8) else {
        print("Error: Could not convert marker to Data.")
        return nil
    }
    // Convert start marker to Data
    guard let endMarkerData = endMarker.data(using: .utf8) else {
        print("Error: Could not convert marker to Data.")
        return nil
    }

    // Combine marker + encrypted text
    let finalData = startMarkerData + encryptedTextData + endMarkerData

    // Find the iEND Marker
    let pngEndMarker: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82] // iEND chunk
    
    if let iendRange = imageData.range(of: Data(pngEndMarker)) {
        // Insert the marker + encrypted text before iEND
        var modifiedData = imageData
        modifiedData.insert(contentsOf: finalData, at: iendRange.lowerBound)

        // Debugging: Print hex preview to verify text was added
        print("Modified Image Data (Last 100 Bytes):")
        print(Array(modifiedData.suffix(100))) // Print last 100 bytes to check

        return modifiedData
    } else {
        print("Error: PNG iEND chunk not found.")
        return nil
    }
}





func createAESKey(from password: String) -> Data {
    let hashed = SHA256.hash(data: password.data(using: .utf8) ?? Data())
    return Data(hashed) // Always 32 bytes
}


func encryptText(text: String, password: String) -> Data? {
    let keyData = createAESKey(from: password) // Generate AES key

    guard let dataToEncrypt = text.data(using: .utf8) else {
        print("Error: Could not convert text to Data.")
        return nil
    }

    let bufferSize = dataToEncrypt.count + kCCBlockSizeAES128
    var encryptedData = Data(count: bufferSize)

    var numBytesEncrypted: size_t = 0
    let status = encryptedData.withUnsafeMutableBytes { encryptedBytes in
        dataToEncrypt.withUnsafeBytes { dataBytes in
            keyData.withUnsafeBytes { keyBytes in
                CCCrypt(
                    CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionPKCS7Padding),
                    keyBytes.baseAddress, kCCKeySizeAES256,
                    nil, // No IV
                    dataBytes.baseAddress, dataToEncrypt.count,
                    encryptedBytes.baseAddress, bufferSize,
                    &numBytesEncrypted
                )
            }
        }
    }

    guard status == kCCSuccess else {
        print("Error: Encryption failed.")
        return nil
    }

    return encryptedData.prefix(numBytesEncrypted)
}



func extractAndDecryptText(from imageData: Data, password: String) -> String? {
    let startMarker = "\n---added text start here---\n"
    let endMarker = "\n---added text end here---\n"
    
    // Convert markers to Data
    guard let startMarkerData = startMarker.data(using: .utf8),
          let endMarkerData = endMarker.data(using: .utf8) else {
        print("Error: Could not convert markers to Data.")
        return nil
    }
    
    // Find the start marker in the image data
    guard let startRange = imageData.range(of: startMarkerData) else {
        showErrorAlert(message: "Could not find encrypted secret, are you sure you are using the correct image?")
        return nil
    }
    
    // Find the end marker in the image data
    guard let endRange = imageData.range(of: endMarkerData, options: [], in: startRange.upperBound..<imageData.endIndex) else {
        print("Error: End marker not found in image data.")
        return nil
    }
    
    // Extract only the encrypted text (between the markers)
    let encryptedTextData = imageData[startRange.upperBound..<endRange.lowerBound]
    
    // Decrypt the extracted text
    guard let decryptedText = decryptText(encryptedData: encryptedTextData, password: password) else {
        print("Error: Decryption failed.")
        return nil
    }
    
    return decryptedText
}






func decryptText(encryptedData: Data, password: String) -> String? {
    let keyData = createAESKey(from: password) // Use fixed key function

    let bufferSize = encryptedData.count + kCCBlockSizeAES128
    var decryptedData = Data(count: bufferSize)

    var numBytesDecrypted: size_t = 0
    let status = decryptedData.withUnsafeMutableBytes { decryptedBytes in
        encryptedData.withUnsafeBytes { encryptedBytes in
            keyData.withUnsafeBytes { keyBytes in
                CCCrypt(
                    CCOperation(kCCDecrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionPKCS7Padding),
                    keyBytes.baseAddress, kCCKeySizeAES256,
                    nil, // No IV
                    encryptedBytes.baseAddress, encryptedData.count,
                    decryptedBytes.baseAddress, bufferSize,
                    &numBytesDecrypted
                )
            }
        }
    }

    guard status == kCCSuccess else {
        print("❌ Error: Decryption failed. Status code: \(status)")
        return nil
    }

    let decryptedBytes = decryptedData.prefix(numBytesDecrypted)
//    print("📝 Raw Decrypted Bytes: \(Array(decryptedBytes))") // Debugging

    if let result = String(data: decryptedBytes, encoding: .utf8) {
        return result
    } else {
        print("❌ Error: Could not convert decrypted data to string.")
        return nil
    }
}

