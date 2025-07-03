//
//  FiendsSessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 27/06/2025.
//

import SwiftUI

struct FiendsSessionScreen: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = FriendsScreenViewModel()
    @State private var invitedUserId = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Utilisateurs Disponibles
                    SectionCard(title: "Utilisateurs disponibles") {
                        ForEach(viewModel.allUsers) { user in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(user.id)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    invitedUserId = user.id
                                    viewModel.sendFriendRequest(to: user.id)
                                }) {
                                    Text("Inviter")
                                        .padding(.horizontal)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            Divider()
                        }
                    }

                    // MARK: - Mes Amis
                    SectionCard(title: "Mes amis") {
                        ForEach(viewModel.friends) { friend in
                            NavigationLink(destination: FriendDetailView(friendId: friend.id, profileViewModel: profileViewModel)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(friend.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(friend.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Divider()
                        }
                    }

                    // MARK: - Messages d'erreur
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // MARK: - Demandes d'amis
                    SectionCard(title: "Mes demandes d'amis") {
                        ForEach(viewModel.receivedRequests) { request in
                            HStack {
                                Text("Demande de: \(request.requestedById)")
                                    .font(.body)
                                Spacer()
                                Button("Accepter") {
                                    viewModel.acceptRequest(id: request.id)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(6)

                                Button("Refuser") {
                                    viewModel.declineRequest(id: request.id)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(6)
                            }
                            Divider()
                        }
                    }
                }
                .padding()
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

struct SectionCard<Content: View>: View {
    var title: String
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            content()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}



struct FriendDetailView: View {
    let friendId: String
    @State private var selectedGenre = "nothing"
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Avatar
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    Text("Préference musicale")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                        Text("Vous avez choisi : \(selectedGenre)")
                            .padding()
                    
                    
                    //NAME
                    HStack {
                        Text("Name")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    if profileViewModel.isAuthenticated {
                        InformationUser(text: profileViewModel.name)
                    } else {
                        InformationUser(text: "Chargement...")
                    }
                    
                    // EMAIL
                    HStack {
                        Text("Email")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    if profileViewModel.isAuthenticated {
                        InformationUser(text: profileViewModel.email)
                    } else {
                        InformationUser(text: "Chargement...")
                    }

                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
                .onAppear {
                    profileViewModel.loadUserInfo()
                    profileViewModel.fetchInvitations()
                }
                .onChange(of: profileViewModel.musicType) { newValue in
                    if !newValue.isEmpty {
                        selectedGenre = newValue
                    }
                }
            }
        }
    }
}

