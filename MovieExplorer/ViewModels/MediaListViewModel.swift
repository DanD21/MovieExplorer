//
//  MediaListViewModel.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation

@MainActor
class MediaListViewModel: ObservableObject {
    private let apiService: TMDBAPIService
    let mediaType: MediaType

    @Published var currentPage: Int = 1
    @Published var genreList: [Genre] = []
    @Published var mediaList: [Media] = []
    @Published var mediaDetails: [Int: MediaDetails] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty {
                // Return to genre-based browsing
                Task {
                    await refreshMediaList()
                }
            } else {
                // Perform search
                Task {
                    await performSearch()
                }
            }
        }
    }

    @Published var selectedGenreID: Int = 0 {
        didSet {
            guard selectedGenreID != oldValue else { return }
            print("Selected Genre ID: \(selectedGenreID)")
            currentPage = 1
            mediaList = []
            Task {
                await fetchMediaByGenre()
            }
        }
    }

    init(mediaType: MediaType, apiService: TMDBAPIService = TMDBAPIService()) {
        self.mediaType = mediaType
        self.apiService = apiService
        Task {
            await fetchGenreList()
        }
    }

    // MARK: - Genre Fetching

    func fetchGenreList() async {
        isLoading = true
        errorMessage = nil

        do {
            let genres = try await apiService.fetchGenres(for: mediaType)
            genreList = genres
            if let firstGenre = genreList.first {
                selectedGenreID = firstGenre.id
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching genre list: \(error)")
        }

        isLoading = false
    }

    // MARK: - Media Fetching

    func fetchMediaByGenre() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("Fetching media for genre ID: \(selectedGenreID), media type: \(mediaType)")

        do {
            let media = try await apiService.discoverMedia(
                genreID: selectedGenreID,
                page: currentPage,
                mediaType: mediaType
            )
            mediaList += media
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching media: \(error)")
        }

        isLoading = false
    }

    // MARK: - Search

    func performSearch() async {
        guard !searchQuery.isEmpty else { return }
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1
        mediaList = []

        do {
            let media = try await apiService.searchMedia(
                query: searchQuery,
                page: currentPage,
                mediaType: mediaType
            )
            mediaList = media
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching media: \(error)")
        }

        isLoading = false
    }

    // MARK: - Details Fetching

    func fetchDetails(for media: Media) async {
        // Skip if we already have details
        guard mediaDetails[media.id] == nil else { return }

        do {
            let details = try await apiService.fetchMediaDetails(
                id: media.id,
                mediaType: mediaType
            )
            mediaDetails[media.id] = details
        } catch {
            print("Error fetching media details: \(error)")
        }
    }

    // MARK: - Pagination

    func loadMoreData() async {
        guard !isLoading else { return }
        currentPage += 1

        if searchQuery.isEmpty {
            await fetchMediaByGenre()
        } else {
            await loadMoreSearchResults()
        }
    }

    private func loadMoreSearchResults() async {
        guard !searchQuery.isEmpty else { return }
        guard !isLoading else { return }

        isLoading = true

        do {
            let media = try await apiService.searchMedia(
                query: searchQuery,
                page: currentPage,
                mediaType: mediaType
            )
            mediaList += media
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading more search results: \(error)")
        }

        isLoading = false
    }

    // MARK: - Refresh

    func refreshMediaList() async {
        currentPage = 1
        mediaList = []
        mediaDetails = [:]
        errorMessage = nil

        if searchQuery.isEmpty {
            await fetchMediaByGenre()
        } else {
            await performSearch()
        }
    }
}
