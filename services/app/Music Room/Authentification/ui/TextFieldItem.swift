//
//  TextField.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct TextFieldItem: View {
    var text: String
    @Binding var input: String
    
    var body: some View {
        VStack {
            TextField(
                    text,
                    text: $input
            )
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .border(Color(red: 235/255, green: 235/255, blue: 235/255), width: 1)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}

#Preview {
    @Previewable @State var sessionName: String = ""
    TextFieldItem(
        text: "Name",
        input: $sessionName
    )
}
