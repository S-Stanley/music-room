//
//  ControlScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct ControlScreen: View {
    @State private var isHomeView: Bool = true
    
    var body: some View {
        VStack {
            if isHomeView {
                HomeScreen()
            } else {
                Profile()
            }
            
            MainTabView()
        }
        .padding()
    }
}


#Preview {
    ControlScreen()
}
