//
//  WatchedMedia.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import SwiftData

enum WatchStatus: String, Codable, CaseIterable {
    case wantToWatch = "Want to Watch"
    case watching = "Watching"
    case watched = "Watched"
    case onHold = "On Hold"
    case dropped = "Dropped"

    var icon: String {
        switch self {
        case .wantToWatch: return "bookmark"
        case .watching: return "play.circle"
        case .watched: return "checkmark.circle"
        case .onHold: return "pause.circle"
        case .dropped: return "xmark.circle"
        }
    }

    var color: String {
        switch self {
        case .wantToWatch: return "blue"
        case .watching: return "green"
        case .watched: return "purple"
        case .onHold: return "orange"
        case .dropped: return "red"
        }
    }
}

enum WatchMood: String, Codable, CaseIterable {
    case relaxing = "Relaxing"
    case thrilling = "Thrilling"
    case thoughtful = "Thoughtful"
    case entertaining = "Entertaining"
    case emotional = "Emotional"
    case scary = "Scary"

    var icon: String {
        switch self {
        case .relaxing: return "cloud.sun"
        case .thrilling: return "bolt"
        case .thoughtful: return "brain.head.profile"
        case .entertaining: return "popcorn"
        case .emotional: return "heart"
        case .scary: return "moon.stars"
        }
    }
}

@Model
final class WatchedMedia {
    @Attribute(.unique) var mediaID: Int
    var title: String
    var posterPath: String?
    var mediaTypeValue: String // "movie" or "tv"

    var status: String // WatchStatus raw value
    var personalRating: Double? // 0-10
    var personalNotes: String?

    var dateAdded: Date
    var dateWatched: Date?
    var dateLastUpdated: Date

    var rewatchCount: Int
    var currentEpisode: Int? // For TV shows
    var totalEpisodes: Int? // For TV shows

    var watchMoodValue: String? // WatchMood raw value
    var whereWatched: String? // "Netflix", "Theater", etc.

    // Computed properties
    var watchStatus: WatchStatus {
        get { WatchStatus(rawValue: status) ?? .wantToWatch }
        set { status = newValue.rawValue }
    }

    var watchMood: WatchMood? {
        get {
            guard let value = watchMoodValue else { return nil }
            return WatchMood(rawValue: value)
        }
        set { watchMoodValue = newValue?.rawValue }
    }

    var mediaType: MediaType {
        get { mediaTypeValue == "tv" ? .tv : .movie }
        set { mediaTypeValue = newValue == .tv ? "tv" : "movie" }
    }

    var progressPercentage: Double? {
        guard let current = currentEpisode, let total = totalEpisodes, total > 0 else {
            return nil
        }
        return (Double(current) / Double(total)) * 100
    }

    init(
        mediaID: Int,
        title: String,
        posterPath: String?,
        mediaType: MediaType,
        status: WatchStatus = .wantToWatch
    ) {
        self.mediaID = mediaID
        self.title = title
        self.posterPath = posterPath
        self.mediaTypeValue = mediaType == .tv ? "tv" : "movie"
        self.status = status.rawValue
        self.dateAdded = Date()
        self.dateLastUpdated = Date()
        self.rewatchCount = 0
    }

    convenience init(from media: Media, status: WatchStatus = .wantToWatch, mediaType: MediaType) {
        self.init(
            mediaID: media.id,
            title: media.displayName,
            posterPath: media.posterPath,
            mediaType: mediaType,
            status: status
        )
    }

    func updateStatus(_ newStatus: WatchStatus) {
        watchStatus = newStatus
        dateLastUpdated = Date()

        if newStatus == .watched && dateWatched == nil {
            dateWatched = Date()
        }
    }

    func addRewatch(mood: WatchMood? = nil, whereWatched: String? = nil) {
        rewatchCount += 1
        dateWatched = Date()
        dateLastUpdated = Date()
        if let mood = mood {
            self.watchMood = mood
        }
        if let where = whereWatched {
            self.whereWatched = whereWatched
        }
    }

    func updateProgress(currentEpisode: Int, totalEpisodes: Int) {
        self.currentEpisode = currentEpisode
        self.totalEpisodes = totalEpisodes
        dateLastUpdated = Date()

        // Auto-update status based on progress
        if currentEpisode >= totalEpisodes {
            watchStatus = .watched
            dateWatched = Date()
        } else if currentEpisode > 0 {
            watchStatus = .watching
        }
    }
}

// MARK: - Statistics Helper

extension WatchedMedia {
    static func statistics(from items: [WatchedMedia]) -> WatchStatistics {
        let watched = items.filter { $0.watchStatus == .watched }
        let totalWatchTime = watched.count * 120 // Rough estimate: 2 hours per item

        let genreCounts = Dictionary(grouping: watched) { item in
            // This would need genre info - placeholder
            "Unknown"
        }

        let avgRating = watched.compactMap { $0.personalRating }.reduce(0, +) / Double(max(watched.count, 1))

        return WatchStatistics(
            totalWatched: watched.count,
            totalWatchTime: totalWatchTime,
            averageRating: avgRating,
            mostWatchedGenre: genreCounts.max(by: { $0.value.count < $1.value.count })?.key ?? "N/A"
        )
    }
}

struct WatchStatistics {
    let totalWatched: Int
    let totalWatchTime: Int // in minutes
    let averageRating: Double
    let mostWatchedGenre: String

    var totalWatchTimeFormatted: String {
        let hours = totalWatchTime / 60
        let days = hours / 24
        if days > 0 {
            return "\(days)d \(hours % 24)h"
        }
        return "\(hours)h"
    }
}
