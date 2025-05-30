//
//  CreationSessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 14/03/2025.
//

import SwiftUI

struct CreationSessionScreen: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @State private var sessionName: String = ""
    @State private var sessionType: String = "PUBLIC"
    @State private var orderType: String = "VOTE"
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isSessionCreated = false
    @State private var createdSessionId: String = ""
    @State private var createdSessionName: String = ""
    
    let userToken: String = User.load()?.token ?? ""
    let userName: String = User.load()?.name ?? ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Create a Session")
                    .font(.title)
                    .padding()

                TextField("Session Name", text: $sessionName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text("Ordre de lecture")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)

                Picker("Ordre de lecture", selection: $orderType) {
                    Text("Vote").tag("VOTE")
                    Text("Position").tag("POSITION")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)

                Picker("Session Type", selection: $sessionType) {
                    Text("Public").tag("PUBLIC")
                    Text("Private").tag("PRIVATE")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if sessionType == "PRIVATE" {
                    SecureField("Enter password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    let sessionPassword = sessionType == "PRIVATE" ? password : nil
                    
                    homeViewModel.createSession(name: sessionName, type: sessionType, orderType: orderType,password: sessionPassword, adminToken: userToken) { success, sessionId in
                        if success, let sessionId = sessionId {
                            createdSessionId = sessionId // ✅ Stocke l'ID
                            createdSessionName = sessionName
                            isSessionCreated = true
                        } else {
                            errorMessage = "Failed to create session"
                        }
                    }
                }) {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationDestination(isPresented: $isSessionCreated) {
                SessionScreen(sessionId: createdSessionId, nameSession: createdSessionName, creatorUserName: userName, orderType: orderType)
            }
        }
    }
}


#Preview {
    CreationSessionScreen()
}

