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
    var sessionId: String
    var nameSession: String
    var nameAdmin: String

    @State private var selectedScreen: String = "Playlist"
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(nameSession)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Admin: \(nameAdmin)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .padding()
                }

                
                NavigationLink(destination: SettingScreen()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .padding()
                }
                
                Button(action: {
                    audioPlayer.stop()
                    quitterLaSession()
                }) {
                    Image(systemName: "arrow.forward.square.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .padding()
                }
            }
            
            // Barre de navigation
            NavigationBar(selectedOption: $selectedScreen, text: "Playlist", text2: "Add music")
                .padding(.bottom, 5)


            Spacer()

            switch selectedScreen {
            case "Playlist":
                PlaylistScreen(musicViewModel: musicViewModel, playlistId: sessionId)
            case "Add music":
                MusicScreen(musicViewModel: musicViewModel, playlistId: sessionId)
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

    func quitterLaSession() {
        presentationMode.wrappedValue.dismiss()
    }
}
