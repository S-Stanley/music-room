//
//  ContentView.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/12/2024.
//

import SwiftUI
import SwiftData

struct Authentification: View {
    @StateObject private var authViewModel = AuthViewModel()

    @State private var selectedOption: String = "Sign in"

    var body: some View {
        if authViewModel.isAuthenticated {
            NavigationScreen()
        } else {
            VStack(spacing: 24) {
                Text("Music Room")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)

                NavigationBar(selectedOption: $selectedOption, text: "Sign in", text2: "Sign up")

                switch selectedOption {
                case "Sign in":
                    SignInScreen(authViewModel: authViewModel)
                case "Sign up":
                    SignUpScreen(authViewModel: authViewModel)
                default:
                    Text("Unknown action")
                }

                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        }
    }
}


#Preview {
    Authentification()
        .modelContainer(for: Item.self, inMemory: true)
}
