//
//  TVShowsListView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 21.08.2023.
//

import SwiftUI

struct TVShowListView: View {
    @StateObject var viewModel: TVShowListViewModel
    @Binding var selectedMedia: Media?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchQuery, placeholder: "Search TV shows...")

                // Genre Selection (hidden during search)
                if viewModel.searchQuery.isEmpty {
                    GenreSelectionView(
                        genres: viewModel.genreList,
                        selectedGenreID: $viewModel.selectedGenreID
                    )
                }

                // Content
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.refreshMediaList()
                        }
                    }
                } else if viewModel.isLoading && viewModel.mediaList.isEmpty {
                    LoadingView(message: "Loading TV shows...")
                } else if viewModel.mediaList.isEmpty {
                    EmptyStateView(
                        message: viewModel.searchQuery.isEmpty
                            ? "No TV shows found in this genre"
                            : "No TV shows found for '\(viewModel.searchQuery)'",
                        icon: "play.tv"
                    )
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 16
                        ) {
                            ForEach(viewModel.mediaList) { media in
                                MediaCell(
                                    media: media,
                                    mediaType: .tv,
                                    details: viewModel.mediaDetails[media.id]
                                )
                                .onAppear {
                                    Task {
                                        await viewModel.fetchDetails(for: media)
                                    }
                                    if media.id == viewModel.mediaList.last?.id {
                                        Task {
                                            await viewModel.loadMoreData()
                                        }
                                    }
                                }
                                .onTapGesture {
                                    selectedMedia = media
                                }
                            }

                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                                .gridCellColumns(2)
                                .gridCellUnsizedAxes(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshMediaList()
                    }
                }
            }
            .navigationTitle("TV Shows")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Search Bar Extension

extension SearchBar {
    init(text: Binding<String>, placeholder: String = "Search movies...") {
        self._text = text
        self.placeholder = placeholder
    }

    private var placeholder: String { "Search..." }
}

// Update SearchBar to accept placeholder
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Update EmptyStateView to accept icon
extension EmptyStateView {
    init(message: String, icon: String = "film") {
        self.message = message
        self.icon = icon
    }

    private var icon: String { "film" }
}

struct EmptyStateView: View {
    let message: String
    var icon: String = "film"

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
