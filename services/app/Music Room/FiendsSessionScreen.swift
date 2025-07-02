//
//  FiendsSessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 27/06/2025.
//

import SwiftUI

struct FiendsSessionScreen: View {
    @StateObject private var viewModel = FriendsScreenViewModel()
    @State private var invitedUserId = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Utilisateurs disponibles")
                    .font(.headline)

                List(viewModel.allUsers) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                            Text(user.id)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Inviter") {
                            invitedUserId = user.id
                            viewModel.sendFriendRequest(to: user.id)
                        }
                    }
                }
                
                Divider().padding()

                Text("Mes amis")
                    .font(.headline)

                List(viewModel.friends) { friend in
                    VStack(alignment: .leading) {
                        Text(friend.name)
                        Text(friend.email).font(.caption).foregroundColor(.gray)
                    }
                }


                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Divider().padding()

                Text("Invitations reçues")
                    .font(.headline)

                
                List(viewModel.receivedRequests) { request in
                            HStack {
                                Text("Demande de: \(request.requestedById)") // adapte selon ce que tu veux afficher
                                Spacer()
                                Button("Accepter") {
                                    viewModel.acceptRequest(id: request.id)
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Pour éviter que le bouton clique la ligne entière

                                Button("Refuser") {
                                    viewModel.declineRequest(id: request.id)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .onAppear {
                            viewModel.fetchFriendRequests()
                        }
                        

            }
            .navigationTitle("Amis")
            .onAppear {
                viewModel.fetchAllUsers()
                viewModel.fetchFriendRequests()
                viewModel.fetchFriends()
            }
        }
    }
}


#Preview {
    FiendsSessionScreen()
}

