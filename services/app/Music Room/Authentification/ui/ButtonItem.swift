//
//  ButtonItem.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct ButtonItem: View {
    var text: String
    var isActive: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .foregroundColor(isActive ? Color.black : Color.gray)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isActive ? Color(red: 248/255, green: 248/255, blue: 248/255) : Color.gray.opacity(0.0))
                .foregroundColor(isActive ? .white : .black)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ButtonItem(text: "Sign in", isActive: true, action: {}
        
    )
}
