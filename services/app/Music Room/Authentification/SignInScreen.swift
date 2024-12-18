//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignInScreen: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome back,")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("good to see you again")
                .foregroundColor(Color.gray)
                .padding(.bottom, 40)
            
            TextFieldItem(text: "Email")
            TextFieldItem(text: "Password")
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SignInScreen()
}
