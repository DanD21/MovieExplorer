//
//  ContentView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 17.08.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var movieViewModel = MovieListViewModel(mediaType: .movie)
    @StateObject private var tvShowViewModel = TVShowListViewModel()
    @StateObject private var watchlistService: WatchlistService
    @State private var selectedMedia: Media? = nil

    init() {
        // Create a temporary context for initialization
        // This will be replaced by the environment model context
        let container = try! ModelContainer(for: WatchedMedia.self)
        let service = WatchlistService(modelContext: container.mainContext)
        _watchlistService = StateObject(wrappedValue: service)
    }

    var body: some View {
        TabView {
            MovieListView(viewModel: movieViewModel, selectedMedia: $selectedMedia)
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
                .environmentObject(watchlistService)

            TVShowListView(viewModel: tvShowViewModel, selectedMedia: $selectedMedia)
                .tabItem {
                    Label("TV Shows", systemImage: "play.tv")
                }
                .environmentObject(watchlistService)

            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "bookmark.fill")
                }
                .environmentObject(watchlistService)
        }
        .sheet(item: $selectedMedia) { media in
            MediaDetailsView(media: media)
                .environmentObject(watchlistService)
        }
        .onAppear {
            // Update watchlist service with environment context
            let newService = WatchlistService(modelContext: modelContext)
            watchlistService.watchedItems = newService.watchedItems
        }
    }
}

#Preview {
    ContentView()
}
