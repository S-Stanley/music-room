//
//  ContentView.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/12/2024.
//

import SwiftUI
import SwiftData

struct Authentification: View {
    @State private var selectedOption: String = "Sign in"
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Music Room")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            NavigationBar(selectedOption: $selectedOption)

            switch selectedOption {
            case "Sign in":
                SignInScreen()
            case "Sign up":
                SignUpScreen()
            default:
                Text("Unknown action")
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    Authentification()
        .modelContainer(for: Item.self, inMemory: true)
}
