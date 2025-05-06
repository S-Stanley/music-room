//
//  ForgotPassword.swift
//  Music Room
//
//  Created by Nathan Bechon on 06/05/2025.
//

import SwiftUI

struct ForgotPassword: View {
//    @ObservedObject var authViewModel: AuthViewModel
    @State private var newPassword: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Forgot password ?")
            TextField("New password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                //APPEL API
            }) {
                Text("Send")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    ForgotPassword()
}
