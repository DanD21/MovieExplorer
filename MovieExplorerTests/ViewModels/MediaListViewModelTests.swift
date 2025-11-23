//
//  MediaListViewModelTests.swift
//  MovieExplorerTests
//
//  Created by Dan Danilescu on 24.08.2023.
//

import XCTest
@testable import MovieExplorer

@MainActor
final class MediaListViewModelTests: XCTestCase {
    var viewModel: TestableMediaListViewModel!
    var mockAPIService: MockTMDBAPIService!

    override func setUp() async throws {
        mockAPIService = MockTMDBAPIService()
        viewModel = TestableMediaListViewModel(
            mediaType: .movie,
            apiService: mockAPIService
        )
        // Wait for initial load
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }

    override func tearDown() async throws {
        await mockAPIService.reset()
        viewModel = nil
        mockAPIService = nil
    }

    // MARK: - Genre Fetching Tests

    func testFetchGenreListSuccess() async throws {
        // Given
        await mockAPIService.reset()

        // When
        await viewModel.fetchGenreList()

        // Then
        XCTAssertEqual(viewModel.genreList.count, 3)
        XCTAssertEqual(viewModel.genreList.first?.name, "Action")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)

        let called = await mockAPIService.fetchGenresCalled
        XCTAssertTrue(called)
    }

    func testFetchGenreListFailure() async throws {
        // Given
        await mockAPIService.setShouldFail(true)

        // When
        await viewModel.fetchGenreList()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.genreList.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Media Fetching Tests

    func testFetchMediaByGenreSuccess() async throws {
        // Given
        await viewModel.fetchGenreList()
        viewModel.selectedGenreID = 28

        // When
        await viewModel.fetchMediaByGenre()

        // Then
        XCTAssertEqual(viewModel.mediaList.count, 2)
        XCTAssertEqual(viewModel.mediaList.first?.title, "Test Movie 1")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchMediaByGenreFailure() async throws {
        // Given
        await mockAPIService.setShouldFail(true)
        viewModel.selectedGenreID = 28

        // When
        await viewModel.fetchMediaByGenre()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.mediaList.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Search Tests

    func testSearchSuccess() async throws {
        // Given
        viewModel.searchQuery = "Test Movie 1"

        // When
        await viewModel.performSearch()

        // Then
        XCTAssertEqual(viewModel.mediaList.count, 1)
        XCTAssertEqual(viewModel.mediaList.first?.title, "Test Movie 1")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchEmptyQuery() async throws {
        // Given
        viewModel.searchQuery = ""

        // When
        await viewModel.performSearch()

        // Then - Should not perform search with empty query
        let called = await mockAPIService.searchMediaCalled
        XCTAssertFalse(called)
    }

    // MARK: - Details Fetching Tests

    func testFetchDetailsSuccess() async throws {
        // Given
        let media = Media(
            id: 1,
            title: "Test",
            rating: 8.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )

        // When
        await viewModel.fetchDetails(for: media)

        // Then
        XCTAssertNotNil(viewModel.mediaDetails[1])
        XCTAssertEqual(viewModel.mediaDetails[1]?.budget, 100_000_000)

        let called = await mockAPIService.fetchMediaDetailsCalled
        XCTAssertTrue(called)
    }

    func testFetchDetailsSkipsIfAlreadyFetched() async throws {
        // Given
        let media = Media(
            id: 1,
            title: "Test",
            rating: 8.0,
            posterPath: nil,
            genreIDs: nil,
            overview: nil,
            name: nil
        )
        await viewModel.fetchDetails(for: media)
        await mockAPIService.reset()

        // When - Fetch again
        await viewModel.fetchDetails(for: media)

        // Then - Should not call API again
        let called = await mockAPIService.fetchMediaDetailsCalled
        XCTAssertFalse(called)
    }

    // MARK: - Pagination Tests

    func testLoadMoreData() async throws {
        // Given
        await viewModel.fetchGenreList()
        viewModel.selectedGenreID = 28
        await viewModel.fetchMediaByGenre()
        let initialCount = viewModel.mediaList.count

        // When
        await viewModel.loadMoreData()

        // Then
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertGreaterThanOrEqual(viewModel.mediaList.count, initialCount)
    }

    func testLoadMoreDataPreventsMultipleLoads() async throws {
        // Given
        viewModel.isLoading = true

        // When
        await viewModel.loadMoreData()

        // Then - Should not increment page
        XCTAssertEqual(viewModel.currentPage, 1)
    }

    // MARK: - Refresh Tests

    func testRefreshMediaList() async throws {
        // Given
        viewModel.mediaList = [
            Media(id: 99, title: "Old", rating: 5.0, posterPath: nil, genreIDs: nil, overview: nil, name: nil)
        ]
        viewModel.currentPage = 5
        viewModel.selectedGenreID = 28

        // When
        await viewModel.refreshMediaList()

        // Then
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertNotEqual(viewModel.mediaList.first?.id, 99) // Old data cleared
        XCTAssertTrue(viewModel.mediaDetails.isEmpty)
    }

    // MARK: - Loading State Tests

    func testLoadingStatesDuringFetch() async throws {
        // Given
        await mockAPIService.reset()

        // When - Start fetching
        let fetchTask = Task {
            await viewModel.fetchMediaByGenre()
        }

        // Check loading state immediately
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        // Then - Should complete and set loading to false
        await fetchTask.value
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - Testable ViewModel

@MainActor
class TestableMediaListViewModel: MediaListViewModel {
    init(mediaType: MediaType, apiService: MockTMDBAPIService) {
        super.init(mediaType: mediaType, apiService: apiService)
    }
}

// MARK: - Mock Service Extension

extension MockTMDBAPIService {
    func setShouldFail(_ value: Bool) async {
        shouldFail = value
    }
}
