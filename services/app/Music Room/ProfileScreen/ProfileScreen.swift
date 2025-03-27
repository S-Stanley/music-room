//
//  Profile.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct ProfileScreen: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var isPopUpPassword: Bool = false
    @State private var isPopUpEmail: Bool = false
    
    var body: some View {
        ZStack { // Pour pouvoir afficher la popup au-dessus
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
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
            .onAppear {
                profileViewModel.loadUserInfo()
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
    }
}

#Preview {
    @Previewable @StateObject var profileViewModel = ProfileViewModel()
    ProfileScreen(profileViewModel: profileViewModel)
}
