//
//  NavigationBar.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct NavigationBar: View {
    @Binding var selectedOption: String
    var text: String
    var text2: String
    
    var body: some View {
        HStack(spacing: 20) {
            ButtonItem(
                text: text,
                isActive: selectedOption == text,
                action: {
                    selectedOption = text
                }
            )
            ButtonItem(
                text: text2,
                isActive: selectedOption == text2,
                action: {
                    selectedOption = text2
                }
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 230/255, green: 230/255, blue: 230/255))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    NavigationBar(
        selectedOption: Binding<String>
            .constant("Sign in"),
        text: "",
        text2: ""
    )
}
