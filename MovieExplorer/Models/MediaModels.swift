//
//  MediaModels.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 18.08.2023.
//

import Foundation

struct MediaResponse: Codable, Sendable {
    let results: [Media]
}

struct GenreListResponse: Codable, Sendable {
    let genres: [Genre]
}

struct Media: Codable, Identifiable, Sendable, Hashable {
    let id: Int
    let title: String?
    let rating: Double
    let posterPath: String?
    let genreIDs: [Int]?
    let overview: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case rating = "vote_average"
        case posterPath = "poster_path"
        case genreIDs = "genre_ids"
        case overview
        case name
    }

    // Computed property for display name
    var displayName: String {
        title ?? name ?? "Unknown Title"
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
    }
}

struct MediaDetails: Codable, Sendable {
    let budget: Int?
    let revenue: Int?
    let lastAirDate: String?
    let lastEpisodeName: LastEpisodeToAir?

    enum CodingKeys: String, CodingKey {
        case budget
        case revenue
        case lastAirDate = "last_air_date"
        case lastEpisodeName = "last_episode_to_air"
    }

    var formattedBudget: String? {
        guard let budget = budget else {
            return nil
        }
        return Self.formatValue(budget)
    }

    var formattedRevenue: String? {
        guard let revenue = revenue else {
            return nil
        }
        return Self.formatValue(revenue)
    }

    var formattedLastAirDate: String? {
        guard let lastAirDate = lastAirDate else {
            return nil
        }
        return Self.formatDate(lastAirDate)
    }

    // MARK: - Static Cached Formatters

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    // MARK: - Static Formatting Methods

    private static func formatValue(_ value: Int) -> String {
        let million: Double = 1_000_000
        let millionValue = Double(value) / million
        return String(format: "%.1fM", millionValue)
    }

    private static func formatDate(_ date: String) -> String {
        if let formattedDate = inputDateFormatter.date(from: date) {
            return outputDateFormatter.string(from: formattedDate)
        }
        return date
    }
}

struct LastEpisodeToAir: Codable, Sendable {
    let id: Int
    let name: String?
}

enum MediaType: Sendable {
    case movie
    case tv
}

struct Genre: Codable, Identifiable, Sendable, Hashable {
    let id: Int
    let name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.id == rhs.id
    }
}
