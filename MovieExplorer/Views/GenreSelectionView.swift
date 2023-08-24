//
//  GenreSelectionView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 21.08.2023.
//

import SwiftUI

struct GenreSelectionView: View {
    let genres: [Genre]
    @Binding var selectedGenreID: Int
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(genres) { genre in
                    Button(action: {
                        selectedGenreID = genre.id
                    }) {
                        Text(genre.name)
                            .padding(6)
                            .background(selectedGenreID == genre.id ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .font(.headline)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}
