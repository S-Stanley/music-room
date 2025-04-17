//
//  Profile.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct ProfileScreen: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var isPopUpPassword: Bool = false
    @State private var isPopUpEmail: Bool = false
    @State private var navigateToSession: Bool = false
    @State private var selectedSession: Session? = nil
    @State private var sessionCreatorName: String = "unknown"

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
                    
                    // EMAIL
                    HStack {
                        Text("Email")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            isPopUpEmail = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if profileViewModel.isAuthenticated {
                        InformationUser(text: profileViewModel.email)
                    } else {
                        InformationUser(text: "Chargement...")
                    }
                    
                    // PASSWORD
                    HStack {
                        Text("Password")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            isPopUpPassword = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    InformationUser(text: "********")
                    
                    Text("Mes Invitations")
                        .font(.title3)
                        .fontWeight(.semibold)

                    if profileViewModel.invitations.isEmpty {
                        Text("Aucune invitation reçue.")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(profileViewModel.invitations) { invite in
                                    InvitationCard(invite: invite) { session in
                                        homeViewModel.joinSession(session: session, password: nil) { success, username in
                                            if success {
                                                selectedSession = session
                                                sessionCreatorName = username ?? "unknown"
                                                navigateToSession = true
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: 250) // Tu peux adapter la hauteur visible
                    }

                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
                .onAppear {
                    profileViewModel.loadUserInfo()
                    profileViewModel.fetchInvitations() // ⬅️ C'est ça qui manque !
                }
                
                if isPopUpPassword {
                    PopUpChangeInfo(
                        isPresented: $isPopUpPassword,
                        onConfirm: { newPassword in
                            profileViewModel.updatePassword(newPassword: newPassword)
                        },
                        isPassword: true,
                        title: "Change your Password"
                    )
                }

                if isPopUpEmail {
                    PopUpChangeInfo(
                        isPresented: $isPopUpEmail,
                        onConfirm: { newEmail in
                            profileViewModel.updateEmail(newEmail: newEmail.lowercased())
                        },
                        isPassword: false,
                        title: "Change your Email"
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToSession) {
                if let session = selectedSession {
                    SessionScreen(sessionId: session.id, nameSession: session.name, creatorUserName: sessionCreatorName)
                }
            }

        }
    }
}

struct InvitationCard: View {
    let invite: Invitation
    let onJoin: (Session) -> Void

    var body: some View {
        VStack() {
            Text("Playlist: \(invite.playlistName)")
                .font(.headline)
            Text("Invité par: \(invite.inviterUsername)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: {
                let session = Session(
                    id: invite.playlist.id,
                    name: invite.playlist.name,
                    type: invite.playlist.type,
                    password: invite.playlist.password,
                    creatorUserName: invite.invitedBy.name
                )
                onJoin(session)
            }) {
                Text("Rejoindre")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

