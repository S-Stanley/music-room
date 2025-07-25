//
//  SessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 13/03/2025.
//

import SwiftUI

struct SessionScreen: View {
    @StateObject var musicViewModel = MusicViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @ObservedObject var audioPlayer = AudioPlayer.shared
    @StateObject var playlistViewModel: PlaylistViewModel
    var sessionId: String
    var nameSession: String
    var creatorUserName: String
    var orderType: String

    @State private var hasStartedPlayback = false
    @State private var selectedScreen: String = "Playlist"
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNavigationScreen = false
    
    init(sessionId: String, nameSession: String, creatorUserName: String, orderType: String) {
            self.sessionId = sessionId
            self.nameSession = nameSession
            self.creatorUserName = creatorUserName
            self.orderType = orderType
            _playlistViewModel = StateObject(wrappedValue: PlaylistViewModel(playlistId: sessionId))
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(nameSession)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Creator ID: \(creatorUserName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()


                NavigationLink(destination: SettingScreen(playlistId: sessionId, creatorUserName: creatorUserName)) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .padding()
                }

                Button(action: {
                    audioPlayer.stop()
                    playlistViewModel.stopPlayback()
                    navigateToNavigationScreen = true
                    
                }) {
                    Image(systemName: "arrow.forward.square.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .padding()
                }
            }
            
            NavigationLink(destination: NavigationScreen(), isActive: $navigateToNavigationScreen) {
                EmptyView()
            }

            NavigationBar(selectedOption: $selectedScreen, text: "Playlist", text2: "Add music")
                .padding(.bottom, 5)

            Spacer()

            switch selectedScreen {
                case "Playlist":
                    PlaylistScreen(orderType: orderType,playlistViewModel: playlistViewModel, playlistId: sessionId)
                case "Add music":
                    MusicScreen(playlistViewModel: playlistViewModel, musicViewModel: musicViewModel, playlistId: sessionId)
                default:
                    Text("Unknown action")
                        .font(.title2)
                        .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
    }
}
