//
//  Profile.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .font(.system(size: 100))
            Text("Email")
                .font(.title2)
                .padding()
            
            InformationUser(text: "Email")
            
            Text("Password")
                .font(.title2)
                .padding()
            
            InformationUser(text: "********")
        }
    }
}

#Preview {
    Profile()
}
