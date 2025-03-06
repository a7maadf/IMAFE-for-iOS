//
//  ContentView.swift
//  IMAFE for iOS
//
//  Created by Ahmad Salem on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: Data?
    @State private var selectedUIImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var secretText: String = ""
    @State private var passwordText: String = ""
    
    
    
    
    
    var body: some View {
        ZStack {
            Color(red: 0.17, green: 0.00, blue: 0.34)
            VStack {
                Spacer()
                
                
                // Image picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let selectedUIImage {
                        Image(uiImage: selectedUIImage) // Use the stored UIImage
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image("add-image")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .onChange(of: selectedItem) {_ in
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            selectedImage = data  // Store as Data
                            selectedUIImage = UIImage(data: data) // Convert here
                        }
                    }
                }
                
                
                Text("*click on the image to change it")
                    .font(.custom("SF Pro Italic", size: 10))
                    .foregroundColor(Color.gray)
                    .opacity(0.5)
                
                
                Spacer()
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $secretText)
                        .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                        .scrollContentBackground(.hidden)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        .font(.custom("SF Pro Rounded", size: 15))
                    
                    if secretText.isEmpty {
                        Text("Enter your secret here only if encrypting. Leave this field empty when decrypting — the decrypted text will appear here.")
                            .foregroundColor(Color.white.opacity(0.6))
                            .font(.custom("SF Pro Rounded", size: 15))
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing() // Call the function to dismiss keyboard
                }
                
                
                
                
                //                Text("Password")
                //                    .font(.custom("SF Pro Rounded", size: 15))
                //                    .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                //                    .frame(maxWidth: .infinity, alignment: .leading) // LtR alignment
                
                
                SecureField("Enter your password here..", text: $passwordText)
                    .padding()
                    .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                    .font(.custom("SF Pro Rounded", size: 15))
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Call the function to dismiss keyboard
                    }
                
                
                
                
                
                
                
                HStack {
                    Button("Encrypt") {
                        if selectedUIImage == nil {
                            showErrorAlert(message: "Choose an image to encrypt")
                        } else if secretText.isEmpty {
                            showErrorAlert(message: "Enter a secret text to encrypt")
                        } else if passwordText.isEmpty {
                            showErrorAlert(message: "Enter a password to encrypt")
                        }
                        else {
                            if let imageData = encryptImage(image: selectedUIImage!, text: secretText, password: passwordText) {
                                // Save the raw data directly to a file in the Photos album
                                
                                // Create a temporary file URL
                                let temporaryDirectory = FileManager.default.temporaryDirectory
                                let temporaryFileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
                                
                                do {
                                    // Write the data to the temporary file
                                    try imageData.write(to: temporaryFileURL)
                                    
                                    // Use PHPhotoLibrary to save the file
                                    PHPhotoLibrary.shared().performChanges({
                                        // Create a request to save the image
                                        PHAssetCreationRequest.forAsset().addResource(with: .photo, fileURL: temporaryFileURL, options: nil)
                                    }, completionHandler: { success, error in
                                        // Clean up the temporary file
                                        try? FileManager.default.removeItem(at: temporaryFileURL)
                                        
                                        if success {
                                            // Notify success on the main thread
                                            DispatchQueue.main.async {
                                                showSuccessAlert(message: "Encrypted image saved to your gallery successfully!")
                                                secretText = ""
                                                passwordText = ""
                                            }
                                        } else if let error = error {
                                            // Notify error on the main thread
                                            DispatchQueue.main.async {
                                                showErrorAlert(message: "Failed to save image: \(error.localizedDescription)")
                                            }
                                        }
                                    })
                                } catch {
                                    showErrorAlert(message: "Failed to write image data: \(error.localizedDescription)")
                                }
                            } else {
                                showErrorAlert(message: ("Failed to generate encrypted image."))
                            }
                        }
                    }
                    .foregroundColor(Color.white)
                    .frame(width: 100, height: 50)
                    .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                    .cornerRadius(10)
                    .font(.custom("SF Pro Rounded", size: 15))
                    .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                    
                    
                    
                    Button("Decrypt") {
                        if selectedUIImage == nil {
                            showErrorAlert(message: "Choose an image to decrypt")
                        } else {
                            if let extractedText = extractAndDecryptText(from: selectedImage!, password: passwordText) {
                                secretText = extractedText
                            } else {
                                showErrorAlert(message: "Wrong password! Try again")
                            }
                        }
                        
                    }
                    
                    
                    
                    .foregroundColor(Color.white)
                    .frame(width: 100, height: 50)
                    .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                    .cornerRadius(10)
                    .font(.custom("SF Pro Rounded", size: 15))
                    .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                }
                Text("*Secured with AES-256 Encryption")
                    .font(.custom("SF Pro Rounded", size: 10))
                    .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                    .frame(maxWidth: .infinity, alignment: .center) // LtR alignment
                
                Spacer()
                
            }
            
            .padding([.top, .leading, .trailing])
            .keyboardResponsive()
            
            
            
        }
        .ignoresSafeArea()
        
        .onTapGesture {
            UIApplication.shared.endEditing() // Dismiss keyboard
        }
        
        
        
        
    }
    
}






extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}




#Preview {
    ContentView()
}
