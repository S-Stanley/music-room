//
//  HomeScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @State private var showPasswordField = false
    @State private var password = ""
    @State private var selectedSession: Session?
    @State private var passwordErrorMessage = ""
    @State private var isPasswordCorrect = false
    @State private var navigateToSession = false
    @State private var sessionCreatorName: String = "unknown"

    var body: some View {
        NavigationStack {
            VStack {
                Text("Session in progress")
                    .font(.title)
                    .padding()

                if homeViewModel.activeSessions.isEmpty {
                    Text("No active sessions")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(homeViewModel.activeSessions) { session in
                        HStack {
                            Text(session.name)
                                .font(.title3)

                            Spacer()

                            if session.type == "PRIVATE" {
                                Image(systemName: "lock")
                                Button(action: {
                                    self.selectedSession = session
                                    self.showPasswordField = true
                                }) {
                                    Text("Join")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                }
                            } else {
                                Button(action: {
                                    homeViewModel.joinSession(session: session, password: nil) { success, userName in
                                        if success {
                                            self.selectedSession = session
                                            self.sessionCreatorName = userName ?? "unknown"
                                            self.navigateToSession = true
                                        }
                                    }
                                }) {
                                    Text("Join")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .listStyle(PlainListStyle())
                }

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
            .onAppear {
                homeViewModel.fetchActiveSessions { success, error in
                    if !success {
                        print("Erreur: \(error ?? "Inconnue")")
                    }
                }
            }

            .sheet(isPresented: $showPasswordField) {
                VStack {
                    SecureField("Enter password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()

                    if !homeViewModel.passwordErrorMessage.isEmpty {
                        Text(homeViewModel.passwordErrorMessage)
                            .foregroundColor(.red)
                    }

                    Button("Join Session") {
                        if let session = selectedSession {
                            homeViewModel.joinSession(session: session, password: password) { success, userId in
                                if success {
                                    self.showPasswordField = false
                                    self.isPasswordCorrect = true
                                    self.navigateToSession = true
                                }
                                print("Private Session User ID: \(userId ?? "unknown")")
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
                .padding()
                .onDisappear {
                    homeViewModel.passwordErrorMessage = ""
                    password = ""
                }
                .ignoresSafeArea(.keyboard)
            }

            .navigationDestination(isPresented: $navigateToSession) {
                if let session = selectedSession {
                    SessionScreen(sessionId: session.id, nameSession: session.name, creatorUserName: sessionCreatorName)
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}
