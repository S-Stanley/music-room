//
//  FriendInfoScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 04/07/2025.
//

import SwiftUI

struct NonFriendDetailScreen: View {
    let friendId: String
    @ObservedObject var friendDetailViewModel: FriendDetailViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
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
            }
        }
    }
}
