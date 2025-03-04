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
                
                Text("*click on the image to change it")
                    .font(.custom("SF Pro Italic", size: 10))
                    .foregroundColor(Color.gray)
                    .opacity(0.5)

                
                Spacer()
                
                TextEditor(text: .constant("type your secret here..."))
                    .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                    .scrollContentBackground(.hidden)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                    .font(.custom("SF Pro Rounded", size: 15))
                
                
                Text("Password")
                    .font(.custom("SF Pro Rounded", size: 15))
                    .foregroundColor(Color(red: 0.90, green: 0.54, blue: 0.99, opacity: 1.00))
                    .frame(maxWidth: .infinity, alignment: .leading) // LtR alignment
                
                
                SecureField("Password....", text: .constant("password"))
                    .padding()
                    .background(Color(red: 0.47, green: 0.04, blue: 0.72))
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                    .font(.custom("SF Pro Rounded", size: 15))
                
                Button("Save") {
                    print("Button pressed")
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
            
                
            
        }
        .ignoresSafeArea()
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: data)
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
