//
//  InformationUser.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct InformationUser: View {
    var text: String
    
    var body: some View {
        Text(text)
            .frame(width: 300, height: 40)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)

    }
}

#Preview {
    InformationUser(
        text: "Name User"
    )
}
