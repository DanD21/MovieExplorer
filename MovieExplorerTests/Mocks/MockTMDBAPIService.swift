//
//  MockTMDBAPIService.swift
//  MovieExplorerTests
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
@testable import MovieExplorer

actor MockTMDBAPIService: TMDBAPIServiceProtocol {
    var shouldFail = false
    var fetchGenresCalled = false
    var discoverMediaCalled = false
    var fetchMediaDetailsCalled = false
    var searchMediaCalled = false

    var mockGenres: [Genre] = [
        Genre(id: 28, name: "Action"),
        Genre(id: 35, name: "Comedy"),
        Genre(id: 18, name: "Drama")
    ]

    var mockMedia: [Media] = [
        Media(
            id: 1,
            title: "Test Movie 1",
            rating: 8.5,
            posterPath: "/test1.jpg",
            genreIDs: [28],
            overview: "A test movie",
            name: nil
        ),
        Media(
            id: 2,
            title: "Test Movie 2",
            rating: 7.2,
            posterPath: "/test2.jpg",
            genreIDs: [35],
            overview: "Another test movie",
            name: nil
        )
    ]

    var mockDetails = MediaDetails(
        budget: 100_000_000,
        revenue: 500_000_000,
        lastAirDate: nil,
        lastEpisodeName: nil
    )

    func fetchGenres(for mediaType: MediaType) async throws -> [Genre] {
        fetchGenresCalled = true
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockGenres
    }

    func discoverMedia(
        genreID: Int,
        page: Int,
        mediaType: MediaType
    ) async throws -> [Media] {
        discoverMediaCalled = true
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockMedia
    }

    func fetchMediaDetails(id: Int, mediaType: MediaType) async throws -> MediaDetails {
        fetchMediaDetailsCalled = true
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockDetails
    }

    func searchMedia(
        query: String,
        page: Int,
        mediaType: MediaType
    ) async throws -> [Media] {
        searchMediaCalled = true
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1))
        }
        return mockMedia.filter { media in
            media.displayName.lowercased().contains(query.lowercased())
        }
    }

    func reset() {
        shouldFail = false
        fetchGenresCalled = false
        discoverMediaCalled = false
        fetchMediaDetailsCalled = false
        searchMediaCalled = false
    }
}
