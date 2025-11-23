//
//  ImportListView.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import SwiftUI
import PhotosUI

struct ImportListView: View {
    @StateObject private var importService: ListImportService
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var importText: String = ""
    @State private var selectedMediaType: MediaType = .movie
    @State private var showingResults = false

    init(watchlistService: WatchlistService) {
        _importService = StateObject(wrappedValue: ListImportService(watchlistService: watchlistService))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down.on.square")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Import Your Watchlist")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Use AI to quickly import your movie lists from photos or text")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Media Type Selector
                    Picker("Media Type", selection: $selectedMediaType) {
                        Text("Movies").tag(MediaType.movie)
                        Text("TV Shows").tag(MediaType.tv)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Import Methods
                    VStack(spacing: 16) {
                        // Photo Import
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ImportMethodCard(
                                icon: "photo.on.rectangle",
                                title: "Scan Photo",
                                description: "Take or select a photo of your movie list",
                                color: .blue
                            )
                        }
                        .onChange(of: selectedItem) { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await importService.importFromPhoto(image)
                                    showingResults = true
                                }
                            }
                        }

                        // Clipboard Import
                        Button(action: {
                            Task {
                                await importService.importFromClipboard(mediaType: selectedMediaType)
                                showingResults = true
                            }
                        }) {
                            ImportMethodCard(
                                icon: "doc.on.clipboard",
                                title: "Paste from Clipboard",
                                description: "Import from copied text",
                                color: .green
                            )
                        }

                        // Manual Text Import
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Or paste/type here:")
                                .font(.headline)
                                .padding(.horizontal)

                            TextEditor(text: $importText)
                                .frame(height: 150)
                                .padding(4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)

                            Text("Enter one title per line")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            Button(action: {
                                Task {
                                    await importService.importFromText(importText, mediaType: selectedMediaType)
                                    showingResults = true
                                }
                            }) {
                                Text("Import from Text")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(importText.isEmpty ? Color.gray : Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(importText.isEmpty)
                            .padding(.horizontal)
                        }
                    }

                    // Processing Indicator
                    if importService.isProcessing {
                        VStack(spacing: 12) {
                            ProgressView(value: importService.progress, total: 1.0)
                                .progressViewStyle(.linear)
                                .padding(.horizontal)

                            Text(progressMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    // Error Message
                    if let error = importService.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Import Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingResults) {
                if let results = importService.importResults {
                    ImportResultsView(
                        results: results,
                        mediaType: selectedMediaType,
                        importService: importService
                    )
                }
            }
        }
    }

    private var progressMessage: String {
        let progress = importService.progress
        if progress < 0.2 {
            return "Reading text from image..."
        } else if progress < 0.4 {
            return "Parsing movie titles..."
        } else if progress < 0.8 {
            return "Searching TMDb database..."
        } else {
            return "Almost done..."
        }
    }
}

// MARK: - Import Method Card

struct ImportMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Import Results View

struct ImportResultsView: View {
    let results: ImportResults
    let mediaType: MediaType
    let importService: ListImportService

    @Environment(\.dismiss) var dismiss
    @State private var selectedStatus: WatchStatus = .wantToWatch
    @State private var selectedMatches: Set<UUID> = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary
                    VStack(spacing: 12) {
                        HStack(spacing: 30) {
                            StatBadge(
                                value: "\(results.matched.count)",
                                label: "Matched",
                                color: .green
                            )
                            StatBadge(
                                value: "\(results.failed.count)",
                                label: "Failed",
                                color: .red
                            )
                            StatBadge(
                                value: String(format: "%.0f%%", results.successRate * 100),
                                label: "Success",
                                color: .blue
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        // Status Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add as:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Status", selection: $selectedStatus) {
                                ForEach(WatchStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)
                    }
                    .padding()

                    // Matched Items
                    if !results.matched.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Matched Items")
                                    .font(.headline)
                                Spacer()
                                Button(selectedMatches.count == results.matched.count ? "Deselect All" : "Select All") {
                                    if selectedMatches.count == results.matched.count {
                                        selectedMatches.removeAll()
                                    } else {
                                        selectedMatches = Set(results.matched.map { $0.id })
                                    }
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)

                            ForEach(results.matched) { match in
                                MatchedItemRow(
                                    match: match,
                                    isSelected: selectedMatches.contains(match.id)
                                ) {
                                    if selectedMatches.contains(match.id) {
                                        selectedMatches.remove(match.id)
                                    } else {
                                        selectedMatches.insert(match.id)
                                    }
                                }
                            }
                        }
                    }

                    // Failed Items
                    if !results.failed.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Could Not Match (\(results.failed.count))")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(results.failed, id: \.self) { title in
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(title)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            Text("Tip: Try searching for these manually")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Import Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add \(selectedMatches.count)") {
                        addSelectedToWatchlist()
                        dismiss()
                    }
                    .disabled(selectedMatches.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Auto-select high-confidence matches
                selectedMatches = Set(results.matched.filter { $0.confidence >= 0.7 }.map { $0.id })
            }
        }
    }

    private func addSelectedToWatchlist() {
        let matchesToAdd = results.matched.filter { selectedMatches.contains($0.id) }
        importService.addMatchedToWatchlist(matchesToAdd, mediaType: mediaType, status: selectedStatus)
    }
}

struct MatchedItemRow: View {
    let match: MatchedMedia
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(match.media.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if match.title != match.media.displayName {
                        Text("Original: \(match.title)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", match.media.rating))
                            .font(.caption)

                        Circle()
                            .fill(confidenceColor(match.confidence))
                            .frame(width: 6, height: 6)
                        Text(String(format: "%.0f%% match", match.confidence * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
