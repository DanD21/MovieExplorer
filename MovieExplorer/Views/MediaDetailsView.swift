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
    let baseURL = "https://image.tmdb.org/t/p/"
    let imageSize = "w780"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let posterPath = media.posterPath {
                    let imageURL = URL(string: baseURL + imageSize + posterPath)!
                    KFImage(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 300)
                        .cornerRadius(10)
                } else {
                    Color.gray
                        .frame(width: 100, height: 150)
                        .cornerRadius(10)
                }
                
                Text(media.title ?? media.name ?? "Unknown Title")
                    .font(.title)
                
                Text("Rating: \(String(format: "%.1f", media.rating))")
                    .font(.headline)
                
                if let details = media.details {
                    VStack(spacing: 8) {
                        if let budget = details.formattedBudget,
                           let revenue = details.formattedRevenue {
                            DetailRow(title: "Budget", value: "$\(budget)")
                            DetailRow(title: "Revenue", value: "$\(revenue)")
                        }
                        
                        if let lastAirDate = details.formattedLastAirDate,
                           let lastEpisodeName = details.lastEpisodeName?.name {
                            DetailRow(title: "Last Air Date", value: lastAirDate)
                            DetailRow(title: "Last Episode", value: lastEpisodeName)
                        }
                    }
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
        .navigationBarTitle(media.title ?? media.name ?? "Details")
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
