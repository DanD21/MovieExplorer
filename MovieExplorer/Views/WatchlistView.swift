//
//  WatchlistView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import SwiftUI
import SwiftData

struct WatchlistView: View {
    @EnvironmentObject var watchlistService: WatchlistService
    @State private var selectedStatus: WatchStatus = .wantToWatch
    @State private var searchQuery: String = ""
    @State private var selectedItem: WatchedMedia?
    @State private var showStatistics = false

    var filteredItems: [WatchedMedia] {
        let statusFiltered = watchlistService.getItems(withStatus: selectedStatus)

        if searchQuery.isEmpty {
            return statusFiltered
        }
        return statusFiltered.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchQuery, placeholder: "Search your watchlist...")

                // Status Filter
                StatusFilterView(selectedStatus: $selectedStatus)

                if filteredItems.isEmpty {
                    EmptyWatchlistView(status: selectedStatus)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems, id: \.mediaID) { item in
                                WatchlistItemRow(item: item)
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showStatistics = true }) {
                        Image(systemName: "chart.bar")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                WatchlistDetailView(item: item)
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
            }
        }
    }
}

// MARK: - Status Filter View

struct StatusFilterView: View {
    @Binding var selectedStatus: WatchStatus

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WatchStatus.allCases, id: \.self) { status in
                    StatusChip(
                        status: status,
                        isSelected: selectedStatus == status
                    ) {
                        selectedStatus = status
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
}

struct StatusChip: View {
    let status: WatchStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: status.icon)
                Text(status.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Watchlist Item Row

struct WatchlistItemRow: View {
    @EnvironmentObject var watchlistService: WatchlistService
    let item: WatchedMedia

    var body: some View {
        HStack(spacing: 12) {
            // Poster Image Placeholder
            if let posterPath = item.posterPath {
                AsyncImage(url: URL(string: Constants.Images.baseURL + Constants.Images.posterSizeSmall + posterPath)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 90)
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: 60, height: 90)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: item.watchStatus.icon)
                        .font(.caption)
                    Text(item.watchStatus.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                if let rating = item.personalRating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                    }
                }

                if let progress = item.progressPercentage {
                    ProgressView(value: progress, total: 100)
                        .frame(height: 4)
                    Text("Episode \(item.currentEpisode ?? 0) of \(item.totalEpisodes ?? 0)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Quick Actions
            Menu {
                ForEach(WatchStatus.allCases, id: \.self) { status in
                    Button(action: {
                        watchlistService.updateStatus(for: item, to: status)
                    }) {
                        Label(status.rawValue, systemImage: status.icon)
                    }
                }

                Divider()

                Button(role: .destructive, action: {
                    watchlistService.removeFromWatchlist(item)
                }) {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Empty State

struct EmptyWatchlistView: View {
    let status: WatchStatus

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: status.icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No \(status.rawValue) Items")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Start adding movies and shows to your watchlist!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Watchlist Detail View

struct WatchlistDetailView: View {
    @EnvironmentObject var watchlistService: WatchlistService
    @Environment(\.dismiss) var dismiss
    let item: WatchedMedia

    @State private var rating: Double
    @State private var notes: String
    @State private var currentEpisode: String
    @State private var totalEpisodes: String

    init(item: WatchedMedia) {
        self.item = item
        _rating = State(initialValue: item.personalRating ?? 5.0)
        _notes = State(initialValue: item.personalNotes ?? "")
        _currentEpisode = State(initialValue: String(item.currentEpisode ?? 0))
        _totalEpisodes = State(initialValue: String(item.totalEpisodes ?? 0))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Rating") {
                    HStack {
                        Text("Rating:")
                        Spacer()
                        Text(String(format: "%.1f", rating))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $rating, in: 0...10, step: 0.5)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                if item.mediaType == .tv {
                    Section("Progress") {
                        HStack {
                            Text("Current Episode")
                            TextField("Episode", text: $currentEpisode)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Total Episodes")
                            TextField("Total", text: $totalEpisodes)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("Information") {
                    HStack {
                        Text("Added")
                        Spacer()
                        Text(item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                    if let dateWatched = item.dateWatched {
                        HStack {
                            Text("Watched")
                            Spacer()
                            Text(dateWatched.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Rewatch Count")
                        Spacer()
                        Text("\(item.rewatchCount)")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button("Save Changes") {
                        saveChanges()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        watchlistService.updateRating(for: item, rating: rating, notes: notes.isEmpty ? nil : notes)

        if item.mediaType == .tv,
           let current = Int(currentEpisode),
           let total = Int(totalEpisodes) {
            watchlistService.updateProgress(for: item, currentEpisode: current, totalEpisodes: total)
        }
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @EnvironmentObject var watchlistService: WatchlistService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = watchlistService.statistics {
                        StatCard(title: "Total Watched", value: "\(stats.totalWatched)", icon: "checkmark.circle.fill")
                        StatCard(title: "Watch Time", value: stats.totalWatchTimeFormatted, icon: "clock.fill")
                        StatCard(title: "Avg Rating", value: String(format: "%.1f", stats.averageRating), icon: "star.fill")
                        StatCard(title: "Top Genre", value: stats.mostWatchedGenre, icon: "film.fill")
                    } else {
                        Text("No statistics available")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
