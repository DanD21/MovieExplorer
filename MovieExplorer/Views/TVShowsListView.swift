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
            viewModel.mediaType = .tv
            viewModel.fetchGenreList()
            viewModel.fetchMediaByGenre()
        }
    }
}
