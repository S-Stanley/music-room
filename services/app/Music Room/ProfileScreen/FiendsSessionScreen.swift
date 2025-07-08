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
                    // MARK: - Utilisateurs Disponibles (avec état ami/inviter)
                    SectionCard(title: "Utilisateurs disponibles") {
                        ForEach(viewModel.allUsers) { user in
                            let isFriend = viewModel.friends.contains(where: { $0.id == user.id })
                            let info = viewModel.userInfos[user.id]

                            UserRowView(
                                user: user,
                                isFriend: isFriend,
                                userInfo: info,
                                onInvite: {
                                    invitedUserId = user.id
                                    viewModel.sendFriendRequest(to: user.id)
                                }
                            )

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

struct UserRowView: View {
    let user: UserSummary
    let isFriend: Bool
    let userInfo: UserInfo?
    let onInvite: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(user.id)
                    .font(.caption)
                    .foregroundColor(.gray)

                if isFriend, let info = userInfo {
                    VStack(alignment: .leading) {
                        Text("Email : \(info.email)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Genre : \(info.musicType)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            if isFriend {
                Text("Ami")
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            } else {
                Button(action: onInvite) {
                    Text("Inviter")
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}
