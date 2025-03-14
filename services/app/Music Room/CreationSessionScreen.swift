//
//  CreationSessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 14/03/2025.
//

import SwiftUI

struct CreationSessionScreen: View {
    @State private var isPrivateSession: Bool = false
    @State private var sessionName: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Create your session")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            TextFieldItem(
                text: "Name session",
                input: $sessionName
            )
            
            Button(action: {
                isPrivateSession.toggle()
            }) {
                HStack {
                    ZStack {
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .cornerRadius(4)

                        if isPrivateSession {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("Private session")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
        
            if isPrivateSession {
                TextFieldItem(
                    text: "Password",
                    input: $password
                )
            }
            
            ButtonActionItem(
                text: "Create session",
                isActive: true,
                action: {}
            )
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    CreationSessionScreen()
}

