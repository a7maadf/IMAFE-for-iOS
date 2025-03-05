//
//  ContentView.swift
//  IMAFE for iOS
//
//  Created by Ahmad Salem on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var secretText: String = ""
    @State private var passwordText: String = "password"

    
    
    
    var body: some View {
        ZStack {
            Color(red: 0.17, green: 0.00, blue: 0.34)
            VStack {
                Spacer()
                
                
                // Image picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
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
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: data)
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
                                Text("your secret goes here...")
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
                    


                
                
                Button("Save") {
                    if let imageData = encryptImage(image: selectedImage!, text: secretText, password: passwordText) {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("hidden_message_image.png")
                        
                        do {
                            try imageData.write(to: tempURL) // Save file temporarily
                            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
                        } catch {
                            print("Error saving image: \(error)")
                        }
                        
                        
                        if let extractedText = extractAndDecryptText(from: imageData, password: passwordText) {
                            print("Decrypted text: \(extractedText)")
                        } else {
                            print("Failed to extract or decrypt text.")
                        }
                    }
                }
                
                .foregroundColor(Color.white)
                .frame(width: 100, height: 50)
                .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                .cornerRadius(10)
                .font(.custom("SF Pro Rounded", size: 15))
                .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                
                
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
