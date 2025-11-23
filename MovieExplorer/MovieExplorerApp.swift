//
//  MovieExplorerApp.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 17.08.2023.
//

import SwiftUI
import SwiftData

@main
struct MovieExplorerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WatchedMedia.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
