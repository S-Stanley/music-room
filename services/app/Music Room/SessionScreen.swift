//
//  SessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 13/03/2025.
//

import SwiftUI

struct SessionScreen: View {
    var nameSession = "Session 1"
    var nameAdmin = "Admin"
    var body: some View {
        @State var selectedOption: String = "Playlist"
        VStack{
            HStack {
                VStack{
                    Text(nameSession)
                    Text(nameAdmin)
                }
                Image(systemName: "lock")
                    .font(.system(size: 30))
                
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 30))
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 30))
            }
            NavigationBar(selectedOption: $selectedOption, text: "Playlist", text2: "Add music")

            switch selectedOption {
            case "Playlist":
                PlaylistScreen()
            case "Add music":
                MusicScreen()
            default:
                Text("Unknown action")
            }
            
        }
    }
}

struct PlaylistScreen: View {
    var body: some View {
        VStack  {
            Text("Playlist")
        }
    }
}

struct MusicScreen: View {
    var body: some View {
        VStack  {
            Text("Music")
           
        }
    }
}


#Preview {
    SessionScreen()
}
