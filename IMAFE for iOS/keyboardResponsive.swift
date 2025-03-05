//
//  keyboardResponsive.swift
//  IMAFE for iOS
//
//  Created by Ahmad Salem on 3/5/25.
//

import SwiftUI
import Combine

struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var cancellables = Set<AnyCancellable>()
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset)
            .onAppear {
                setupKeyboardObservers()
            }
            .onDisappear {
                cancellables.removeAll()
            }
    }
    
    private func setupKeyboardObservers() {
        // Show keyboard notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                
                let keyboardHeight = keyboardFrame.height
                let bottomInset = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })?
                    .safeAreaInsets.bottom ?? 0
                
                return keyboardHeight - bottomInset
            }
            .sink { height in
                self.offset = height
            }
            .store(in: &cancellables)
        
        // Hide keyboard notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                self.offset = 0
            }
            .store(in: &cancellables)
    }
}

extension View {
    func keyboardResponsive() -> some View {
        modifier(KeyboardResponsiveModifier())
    }
}
