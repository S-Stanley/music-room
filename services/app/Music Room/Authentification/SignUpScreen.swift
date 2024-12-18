//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignUpScreen: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Hello,")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("this is where the music begins")
                .foregroundColor(Color.gray)
                .padding(.bottom, 40)
            
            // Champs de texte
            TextFieldItem(text: "Name")
            TextFieldItem(text: "Email")
            TextFieldItem(text: "Password")
        }
        .padding(.horizontal, 20)
    }
}


#Preview {
    SignUpScreen()
}
