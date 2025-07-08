//
//  SectionCard.swift
//  Music Room
//
//  Created by Nathan Bechon on 04/07/2025.
//

import Foundation
import SwiftUI

struct SectionCard<Content: View>: View {
    var title: String
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            content()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
