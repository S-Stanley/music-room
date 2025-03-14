//
//  HomeScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

struct HomeScreen: View {
    let sessions = [
            "Session 1",
            "Session 2",
            "Session 3",
            "Session 4",
            "Session 5"
        ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Session in progress")
                    .font(.title)
                    .padding()
                
                List(sessions, id: \.self) { session in
                    HStack {
                        Text(session)
                            .font(.title)
                        Spacer()
                        
                        NavigationLink(destination: SessionScreen(nameSession: session, nameAdmin: "Admin")) {
                            Text("Join")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                NavigationLink(destination: CreationSessionScreen()) {
                        Text("Create session")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
            }
        }
    }
}

#Preview {
    HomeScreen()
}
