//
//  Profile.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct ProfileScreen: View {
    @State private var selectedGenre = "nothing"
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var googleViewModel = GoogleAuthViewModel()
    @StateObject private var facebookViewModel = FaceBookViewModel()
    @State private var isPopUpPassword: Bool = false
    @State private var isPopUpEmail: Bool = false
    @State private var isPopUpName: Bool = false
    @State private var navigateToSession: Bool = false
    @State private var selectedSession: Session? = nil
    @State private var sessionCreatorName: String = "unknown"

    let genres = ["HIP_HOP", "HOUSE", "REGGEA", "RNB"   ]
    var body: some View {
        ScrollView {
            NavigationStack {
                ZStack {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack(spacing: 16) {
                            
                            if profileViewModel.isFacebookLinked {
                                Text("✅ Facebook est connecté")
                            } else {
                                Button("Connecter Facebook") {
                                    facebookViewModel.linkFacebookAccount()
                                }
                            }
                            
                            if profileViewModel.isGoogleLinked {
                                Text("✅ Google est connecté")
                            } else {
                                Button("Connecter Google") {
                                    googleViewModel.link()
                                }
                            }


                            Spacer()

                            NavigationLink(destination: FiendsSessionScreen(profileViewModel: profileViewModel)) {
                                Text("Friends")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)

                        
                        
                        //NAME
                        HStack {
                            Text("Name")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                isPopUpName = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
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
                        
                        Text("Préference musicale")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Picker("Genre", selection: $selectedGenre) {
                            ForEach(genres, id: \.self) { genre in
                                Text(genre)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                profileViewModel.updateMusicType(newMusicType: selectedGenre)
                            }) {
                                Text("save ")
                            }
                        }
                        
                        Text("Invitations à une Session")
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
                        profileViewModel.fetchInvitations()
                    }
                    .onChange(of: profileViewModel.musicType) { newValue in
                        if !newValue.isEmpty {
                            selectedGenre = newValue
                        }
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
                        PopUpChangeEmail(
                            isPresented: $isPopUpEmail,
                            onConfirm: { newEmail in
                                isPopUpEmail = false
                                profileViewModel.updateEmail(newEmail: newEmail.lowercased())
                            },
                            title: "Change your Email"
                        )
                    }
                    
                    if isPopUpName{
                        PopUpChangeName(
                            isPresented: $isPopUpName,
                            onConfirm: { newName in
                                profileViewModel.updateName(newName: newName)
                            },
                            title: "Change your Name"
                        )
                    }
                }
                .navigationDestination(isPresented: $navigateToSession) {
                    if let session = selectedSession {
                        SessionScreen(sessionId: session.id, nameSession: session.name, creatorUserName: sessionCreatorName, orderType: session.orderType)
                    }
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
                    creatorUserName: invite.invitedBy.name,
                    orderType: invite.playlist.orderType
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

