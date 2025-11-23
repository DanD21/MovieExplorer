//
//  MediaModelsTests.swift
//  MovieExplorerTests
//
//  Created by Dan Danilescu on 24.08.2023.
//

import XCTest
@testable import MovieExplorer

final class MediaModelsTests: XCTestCase {

    // MARK: - Media Tests

    func testMediaDisplayName() {
        // Test with title
        let movieWithTitle = Media(
            id: 1,
            title: "Test Movie",
            rating: 8.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )
        XCTAssertEqual(movieWithTitle.displayName, "Test Movie")

        // Test with name (TV show)
        let showWithName = Media(
            id: 2,
            title: nil,
            rating: 7.5,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: "Test Show"
        )
        XCTAssertEqual(showWithName.displayName, "Test Show")

        // Test with both (title should win)
        let mediaWithBoth = Media(
            id: 3,
            title: "Movie Title",
            rating: 9.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: "Show Name"
        )
        XCTAssertEqual(mediaWithBoth.displayName, "Movie Title")

        // Test with neither
        let mediaWithNeither = Media(
            id: 4,
            title: nil,
            rating: 6.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )
        XCTAssertEqual(mediaWithNeither.displayName, "Unknown Title")
    }

    func testMediaHashable() {
        let media1 = Media(
            id: 1,
            title: "Test",
            rating: 8.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )

        let media2 = Media(
            id: 1,
            title: "Different Title",
            rating: 7.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )

        // Same ID should be equal
        XCTAssertEqual(media1, media2)

        // Same ID should have same hash
        XCTAssertEqual(media1.hashValue, media2.hashValue)
    }

    func testMediaCodable() throws {
        let json = """
        {
            "id": 123,
            "title": "Test Movie",
            "vote_average": 8.5,
            "poster_path": "/test.jpg",
            "genre_ids": [28, 35],
            "overview": "Test overview"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let media = try decoder.decode(Media.self, from: data)

        XCTAssertEqual(media.id, 123)
        XCTAssertEqual(media.title, "Test Movie")
        XCTAssertEqual(media.rating, 8.5)
        XCTAssertEqual(media.posterPath, "/test.jpg")
        XCTAssertEqual(media.genreIDs, [28, 35])
        XCTAssertEqual(media.overview, "Test overview")
    }

    // MARK: - MediaDetails Tests

    func testFormattedBudget() {
        let details = MediaDetails(
            budget: 100_000_000,
            revenue: nil,
            lastAirDate: nil,
            lastEpisodeName: nil
        )

        XCTAssertEqual(details.formattedBudget, "100.0M")
    }

    func testFormattedRevenue() {
        let details = MediaDetails(
            budget: nil,
            revenue: 250_500_000,
            lastAirDate: nil,
            lastEpisodeName: nil
        )

        XCTAssertEqual(details.formattedRevenue, "250.5M")
    }

    func testFormattedBudgetNil() {
        let details = MediaDetails(
            budget: nil,
            revenue: nil,
            lastAirDate: nil,
            lastEpisodeName: nil
        )

        XCTAssertNil(details.formattedBudget)
    }

    func testFormattedLastAirDate() {
        let details = MediaDetails(
            budget: nil,
            revenue: nil,
            lastAirDate: "2024-01-15",
            lastEpisodeName: nil
        )

        XCTAssertNotNil(details.formattedLastAirDate)
        // Note: Actual format depends on locale
        XCTAssertTrue(details.formattedLastAirDate!.contains("2024"))
    }

    func testMediaDetailsCodable() throws {
        let json = """
        {
            "budget": 150000000,
            "revenue": 500000000,
            "last_air_date": "2024-01-01",
            "last_episode_to_air": {
                "id": 456,
                "name": "Season Finale"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let details = try decoder.decode(MediaDetails.self, from: data)

        XCTAssertEqual(details.budget, 150_000_000)
        XCTAssertEqual(details.revenue, 500_000_000)
        XCTAssertEqual(details.lastAirDate, "2024-01-01")
        XCTAssertEqual(details.lastEpisodeName?.id, 456)
        XCTAssertEqual(details.lastEpisodeName?.name, "Season Finale")
    }

    // MARK: - Genre Tests

    func testGenreHashable() {
        let genre1 = Genre(id: 28, name: "Action")
        let genre2 = Genre(id: 28, name: "Different Name")

        // Same ID should be equal
        XCTAssertEqual(genre1, genre2)

        // Same ID should have same hash
        XCTAssertEqual(genre1.hashValue, genre2.hashValue)
    }

    func testGenreCodable() throws {
        let json = """
        {
            "id": 28,
            "name": "Action"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let genre = try decoder.decode(Genre.self, from: data)

        XCTAssertEqual(genre.id, 28)
        XCTAssertEqual(genre.name, "Action")
    }
}
