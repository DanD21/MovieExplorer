//
//  MovieListView.swift
//
//
//  Created by Dan Danilescu on 21.08.2023.
//

import SwiftUI

struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel
    @Binding var selectedMedia: Media?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchQuery)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

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
                    LoadingView(message: "Loading movies...")
                } else if viewModel.mediaList.isEmpty {
                    EmptyStateView(
                        message: viewModel.searchQuery.isEmpty
                            ? "No movies found in this genre"
                            : "No movies found for '\(viewModel.searchQuery)'"
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
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search movies...", text: $text)
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
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding(.horizontal)
            Button("Retry") {
                onRetry()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
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
