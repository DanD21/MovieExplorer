//
//  Constants.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation

struct Constants {
    static let apiKey = "YOUR_TMDB_API_KEY"

    // TMDB Image Configuration
    struct Images {
        static let baseURL = "https://image.tmdb.org/t/p/"
        static let posterSizeSmall = "w500"
        static let posterSizeLarge = "w780"
    }

    // TMDB API Configuration
    struct API {
        static let baseURL = "https://api.themoviedb.org/3"

        static func genreListURL(for mediaType: MediaType) -> String {
            return "\(baseURL)/genre/\(mediaType == .movie ? "movie" : "tv")/list"
        }

        static func discoverURL(for mediaType: MediaType) -> String {
            return "\(baseURL)/discover/\(mediaType == .movie ? "movie" : "tv")"
        }

        static func detailsURL(for mediaType: MediaType, id: Int) -> String {
            return "\(baseURL)/\(mediaType == .movie ? "movie" : "tv")/\(id)"
        }
    }
}
