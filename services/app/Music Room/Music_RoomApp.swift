//
//  Music_RoomApp.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/12/2024.
//

import SwiftUI
import SwiftData

@main
struct Music_RoomApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Authentification()
        }
        .modelContainer(sharedModelContainer)
    }
}
