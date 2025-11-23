//
//  WatchlistService.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import SwiftData

@MainActor
class WatchlistService: ObservableObject {
    private let modelContext: ModelContext

    @Published var watchedItems: [WatchedMedia] = []
    @Published var statistics: WatchStatistics?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadWatchedItems()
    }

    // MARK: - CRUD Operations

    func addToWatchlist(
        media: Media,
        mediaType: MediaType,
        status: WatchStatus = .wantToWatch
    ) {
        // Check if already exists
        let descriptor = FetchDescriptor<WatchedMedia>(
            predicate: #Predicate { $0.mediaID == media.id }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            // Update existing
            existing.updateStatus(status)
        } else {
            // Add new
            let watchedMedia = WatchedMedia(from: media, status: status, mediaType: mediaType)
            modelContext.insert(watchedMedia)
        }

        saveContext()
        loadWatchedItems()
    }

    func removeFromWatchlist(_ watchedMedia: WatchedMedia) {
        modelContext.delete(watchedMedia)
        saveContext()
        loadWatchedItems()
    }

    func updateStatus(for watchedMedia: WatchedMedia, to newStatus: WatchStatus) {
        watchedMedia.updateStatus(newStatus)
        saveContext()
        loadWatchedItems()
    }

    func updateRating(for watchedMedia: WatchedMedia, rating: Double, notes: String? = nil) {
        watchedMedia.personalRating = rating
        if let notes = notes {
            watchedMedia.personalNotes = notes
        }
        watchedMedia.dateLastUpdated = Date()
        saveContext()
    }

    func updateProgress(
        for watchedMedia: WatchedMedia,
        currentEpisode: Int,
        totalEpisodes: Int
    ) {
        watchedMedia.updateProgress(currentEpisode: currentEpisode, totalEpisodes: totalEpisodes)
        saveContext()
        loadWatchedItems()
    }

    func addRewatch(
        for watchedMedia: WatchedMedia,
        mood: WatchMood? = nil,
        whereWatched: String? = nil
    ) {
        watchedMedia.addRewatch(mood: mood, whereWatched: whereWatched)
        saveContext()
    }

    // MARK: - Queries

    func getWatchedMedia(for mediaID: Int) -> WatchedMedia? {
        let descriptor = FetchDescriptor<WatchedMedia>(
            predicate: #Predicate { $0.mediaID == mediaID }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func getItems(withStatus status: WatchStatus) -> [WatchedMedia] {
        watchedItems.filter { $0.watchStatus == status }
    }

    func getItems(withMood mood: WatchMood) -> [WatchedMedia] {
        watchedItems.filter { $0.watchMood == mood }
    }

    func searchItems(query: String) -> [WatchedMedia] {
        watchedItems.filter { $0.title.lowercased().contains(query.lowercased()) }
    }

    // MARK: - Smart Recommendations

    func getSmartRecommendation(
        mood: WatchMood? = nil,
        maxRuntime: Int? = nil,
        excludeWatched: Bool = true
    ) -> WatchedMedia? {
        var items = watchedItems.filter { $0.watchStatus == .wantToWatch }

        if let mood = mood {
            items = items.filter { $0.watchMood == mood }
        }

        if excludeWatched {
            items = items.filter { $0.watchStatus != .watched }
        }

        // Random selection
        return items.randomElement()
    }

    // MARK: - Statistics

    func calculateStatistics() {
        statistics = WatchedMedia.statistics(from: watchedItems)
    }

    // MARK: - Private Helpers

    private func loadWatchedItems() {
        let descriptor = FetchDescriptor<WatchedMedia>(
            sortBy: [SortDescriptor(\.dateLastUpdated, order: .reverse)]
        )

        do {
            watchedItems = try modelContext.fetch(descriptor)
            calculateStatistics()
        } catch {
            print("Failed to load watched items: \(error)")
            watchedItems = []
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
