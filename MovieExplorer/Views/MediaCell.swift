//
//  MediaCell.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 18.08.2023.
//

import SwiftUI
import Kingfisher

struct MediaCell: View {
    let media: Media
    let baseURL = "https://image.tmdb.org/t/p/"
    let imageSize = "w500"
    
    var body: some View {
        VStack(spacing: 8) {
            if let posterPath = media.posterPath {
                let imageURL = URL(string: baseURL + imageSize + posterPath)!
                KFImage(imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 150)
                    .cornerRadius(10)
            } else {
                Color.gray
                    .frame(width: 100, height: 150)
                    .cornerRadius(10)
            }
            
            Text((media.title ?? media.name) ?? "")
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            HStack {
                Text("Rating: ")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String(format: "%.1f", media.rating))
                    .font(.caption)
            }
            
            if let details = media.details {
                if let budget = details.formattedBudget,
                   let revenue = details.formattedRevenue {
                    HStack {
                        Text("Budget: ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("$" + budget)
                            .font(.caption)
                    }
                    HStack {
                        Text("Revenue: ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("$" + revenue)
                            .font(.caption)
                    }
                }
                
                if let lastAirDate = details.formattedLastAirDate,
                   let lastEpisodeName = details.lastEpisodeName?.name {
                    Text("Last Air Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lastAirDate)
                        .font(.caption)
                    Text("Last Episode")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(lastEpisodeName)
                        .font(.caption)
                }
            }
        }
        .padding()
        .cornerRadius(10)
    }
}
