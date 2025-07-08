//
//  FriendInfoScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 04/07/2025.
//

import SwiftUI

struct FriendDetailScreen: View {
    let friendId: String
    @State private var selectedGenre = "nothing"
    @ObservedObject var friendDetailViewModel: FriendDetailViewModel

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
                    
                    if friendDetailViewModel.isAuthenticated {
                        InformationUser(text: friendDetailViewModel.name)
                    } else {
                        InformationUser(text: "Chargement...")
                    }
                    
                    // EMAIL
                    HStack {
                        Text("Email")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    if friendDetailViewModel.isAuthenticated {
                        InformationUser(text: friendDetailViewModel.email)
                    } else {
                        InformationUser(text: "Chargement...")
                    }

                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
                .onAppear {
                    friendDetailViewModel.loadFriendInfo()
                }
                .onChange(of: friendDetailViewModel.musicType) { newValue in
                    if !newValue.isEmpty {
                        selectedGenre = newValue
                    }
                }
            }
        }
    }
}
