//
//  MediaCell.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 18.08.2023.
//

import SwiftUI
import Kingfisher

struct MediaCell: View {
    @EnvironmentObject var watchlistService: WatchlistService
    let media: Media
    let mediaType: MediaType
    let details: MediaDetails?
    @State private var showingStatusMenu = false

    init(media: Media, mediaType: MediaType, details: MediaDetails? = nil) {
        self.media = media
        self.mediaType = mediaType
        self.details = details
    }

    private var watchedItem: WatchedMedia? {
        watchlistService.getWatchedMedia(for: media.id)
    }

    private var isInWatchlist: Bool {
        watchedItem != nil
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Poster Image
                if let posterPath = media.posterPath,
                   let imageURL = URL(string: Constants.Images.baseURL + Constants.Images.posterSizeSmall + posterPath) {
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

                // Quick Add Button
                Button(action: { showingStatusMenu = true }) {
                    Image(systemName: isInWatchlist ? watchedItem!.watchStatus.icon : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(isInWatchlist ? Color.blue : Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(4)
            }

            Text(media.displayName)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", media.rating))
                    .font(.caption)
            }

            if let watchedItem = watchedItem, let rating = watchedItem.personalRating {
                HStack(spacing: 2) {
                    Text("Your:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .cornerRadius(10)
        .confirmationDialog("Add to Watchlist", isPresented: $showingStatusMenu) {
            ForEach(WatchStatus.allCases, id: \.self) { status in
                Button(status.rawValue) {
                    if let existingItem = watchedItem {
                        watchlistService.updateStatus(for: existingItem, to: status)
                    } else {
                        watchlistService.addToWatchlist(media: media, mediaType: mediaType, status: status)
                    }
                }
            }
            if isInWatchlist {
                Button("Remove from Watchlist", role: .destructive) {
                    if let item = watchedItem {
                        watchlistService.removeFromWatchlist(item)
                    }
                }
            }
        }
    }
}
