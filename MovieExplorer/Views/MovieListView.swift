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
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.mediaType = .movie
            viewModel.fetchGenreList()
            viewModel.fetchMediaByGenre()
        }
    }
}
