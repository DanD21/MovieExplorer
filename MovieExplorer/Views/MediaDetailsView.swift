//
//  MediaDetailsView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 23.08.2023.
//

import SwiftUI
import Kingfisher

struct MediaDetailsView: View {
    let media: Media

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let posterPath = media.posterPath,
                   let imageURL = URL(string: Constants.Images.baseURL + Constants.Images.posterSizeLarge + posterPath) {
                    KFImage(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 300)
                        .cornerRadius(10)
                } else {
                    Color.gray
                        .frame(width: 250, height: 300)
                        .cornerRadius(10)
                }
                
                Text(media.displayName)
                    .font(.title)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", media.rating))
                        .font(.headline)
                    Text("/ 10")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if let overview = media.overview {
                    Text("Overview:")
                        .font(.headline)
                    Text(overview)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(media.displayName)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}
