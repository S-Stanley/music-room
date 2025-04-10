//
//  SettingScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 09/04/2025.
//

import SwiftUI

struct SettingScreen: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Titre Settings
            Text("Settings")
                .font(.largeTitle)
                .bold()

            // Contenu
            Text("Logged-in user")
                .font(.title3)

            Spacer()
        }
        .padding()
    }
}



#Preview {
    SettingScreen()
}
