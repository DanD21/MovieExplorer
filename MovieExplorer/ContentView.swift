//
//  ContentView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 17.08.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var movieViewModel = MovieListViewModel()
    @StateObject private var tvShowViewModel = TVShowListViewModel()
    @State private var selectedMedia: Media? = nil
    
    var body: some View {
        TabView {
            MovieListView(viewModel: movieViewModel, selectedMedia: $selectedMedia)
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            TVShowListView(viewModel: tvShowViewModel, selectedMedia: $selectedMedia)
                .tabItem {
                    Label("TV Shows", systemImage: "play.tv")
                }
        }
        .sheet(item: $selectedMedia) { media in
            MediaDetailsView(media: media)
        }
    }
}

#Preview {
    ContentView()
}
