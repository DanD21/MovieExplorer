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
        VStack {
            GenreSelectionView(genres: viewModel.genreList, selectedGenreID: $viewModel.selectedGenreID)

            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                    Button("Retry") {
                        viewModel.refreshMediaList()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            } else if viewModel.isLoading && viewModel.mediaList.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading movies...")
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.mediaList, id: \.uuid) { media in
                            MediaCell(media: media)
                                .onAppear {
                                    if media.details == nil {
                                        viewModel.fetchDetails(for: media)
                                    }
                                    if media.id == viewModel.mediaList.last?.id {
                                        viewModel.loadMoreData()
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
                                Spacer()
                            }
                            .gridCellColumns(2)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
