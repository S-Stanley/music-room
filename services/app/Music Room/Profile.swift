//
//  Profile.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct Profile: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .font(.system(size: 100))

            HStack {
                Text("Email")
                    .font(.title2)
                Spacer()
                Button(action: {
                        //action
                }) {
                    Image(systemName: "pencil")
                }
            }

            if authViewModel.isAuthenticated {
                InformationUser(text: authViewModel.email)
            } else {
                InformationUser(text: "Chargement...")
            }

            HStack {
                Text("Password")
                    .font(.title2)
                Spacer()
                Button(action: {
                        //action
                }) {
                    Image(systemName: "pencil")
                }
            }

            InformationUser(text: "********")
        }
        .onAppear {
            authViewModel.loadUserInfo()
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
    }
}



#Preview {
    @Previewable @StateObject var authViewModel = AuthViewModel()
    Profile(authViewModel: authViewModel)
}
