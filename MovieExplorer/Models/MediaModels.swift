//
//  MediaModels.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 18.08.2023.
//

import Foundation

struct MediaResponse: Codable {
    let results: [Media]
}

struct GenreListResponse: Codable {
    let genres: [Genre]
}

struct Media: Codable, Identifiable {
    let id: Int
    let uuid = UUID()
    let title: String?
    let rating: Double
    let posterPath: String?
    let genreIDs: [Int]?
    let overview: String?
    let name: String?
    var details: MediaDetails?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case rating = "vote_average"
        case posterPath = "poster_path"
        case genreIDs = "genre_ids"
        case overview
        case name
        case details
    }
}

struct MediaDetails: Codable {
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
        return formatValue(budget)
    }
    
    var formattedRevenue: String? {
        guard let revenue = revenue else {
            return nil
        }
        return formatValue(revenue)
    }
    
    var formattedLastAirDate: String? {
        guard let lastAirDate = lastAirDate else {
            return nil
        }
        return formatDate(lastAirDate)
    }
    
    private func formatValue(_ value: Int) -> String {
        let million: Double = 1_000_000
        let millionValue = Double(value) / million
        return String(format: "%.1fM", millionValue)
    }
    
    private func formatDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let formattedDate = dateFormatter.date(from: date) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: formattedDate)
        }
        return date
    }
}

struct LastEpisodeToAir: Codable {
    let id: Int
    let name: String?
}

enum MediaType {
    case movie
    case tv
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

