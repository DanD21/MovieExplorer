//
//  ListImportService.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import Vision
import UIKit
import NaturalLanguage

@MainActor
class ListImportService: ObservableObject {
    private let apiService: TMDBAPIService
    private let watchlistService: WatchlistService

    @Published var isProcessing: Bool = false
    @Published var progress: Double = 0.0
    @Published var importResults: ImportResults?
    @Published var errorMessage: String?

    init(apiService: TMDBAPIService = TMDBAPIService(), watchlistService: WatchlistService) {
        self.apiService = apiService
        self.watchlistService = watchlistService
    }

    // MARK: - Photo Import (Halo Feature!)

    func importFromPhoto(_ image: UIImage) async {
        isProcessing = true
        progress = 0.0
        errorMessage = nil

        do {
            // Step 1: OCR text from image (20%)
            progress = 0.1
            let extractedText = try await extractTextFrom Image(image)
            progress = 0.2

            // Step 2: Parse movie/show titles (40%)
            let titles = parseMovieTitles(from: extractedText)
            progress = 0.4

            // Step 3: Search and match titles (80%)
            let results = await searchAndMatch(titles: titles)
            progress = 0.8

            // Step 4: Add to watchlist (100%)
            importResults = results
            progress = 1.0

        } catch {
            errorMessage = "Failed to process image: \(error.localizedDescription)"
        }

        isProcessing = false
    }

    // MARK: - Text Import

    func importFromText(_ text: String, mediaType: MediaType = .movie) async {
        isProcessing = true
        progress = 0.0
        errorMessage = nil

        let titles = parseMovieTitles(from: text)
        let results = await searchAndMatch(titles: titles, mediaType: mediaType)
        importResults = results
        progress = 1.0
        isProcessing = false
    }

    // MARK: - Clipboard Import

    func importFromClipboard(mediaType: MediaType = .movie) async {
        guard let text = UIPasteboard.general.string else {
            errorMessage = "No text found in clipboard"
            return
        }

        await importFromText(text, mediaType: mediaType)
    }

    // MARK: - Private Helpers

    private func extractTextFromImage(_ image: UIImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: ImportError.invalidImage)
                return
            }

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ImportError.ocrFailed)
                    return
                }

                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func parseMovieTitles(from text: String) -> [String] {
        // Split by common delimiters
        let lines = text.components(separatedBy: .newlines)

        var titles: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Skip empty lines
            guard !trimmed.isEmpty else { continue }

            // Remove common prefixes (numbers, bullets, dashes)
            var cleaned = trimmed
                .replacingOccurrences(of: "^\\d+\\.?\\s*", with: "", options: .regularExpression)
                .replacingOccurrences(of: "^[-•*]\\s*", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)

            // Remove years in parentheses for better matching
            cleaned = cleaned.replacingOccurrences(of: "\\s*\\(\\d{4}\\)", with: "", options: .regularExpression)

            // Skip very short lines (likely noise)
            guard cleaned.count >= 2 else { continue }

            // Use NLP to filter likely movie titles
            if looksLikeMovieTitle(cleaned) {
                titles.append(cleaned)
            }
        }

        return titles
    }

    private func looksLikeMovieTitle(_ text: String) -> Bool {
        // Skip lines that look like headers or instructions
        let lowercased = text.lowercased()
        let skipWords = ["watch", "list", "todo", "movies", "shows", "see", "my", "to watch"]

        if skipWords.contains(where: { lowercased == $0 }) {
            return false
        }

        // Should have at least one word
        let words = text.components(separatedBy: .whitespaces)
        guard words.count >= 1 else { return false }

        // Use title case detection
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        let tokens = tokenizer.tokens(for: text.startIndex..<text.endIndex)

        // Most words should start with capital letter (title case)
        let capitalizedCount = tokens.filter { range in
            let word = String(text[range])
            return word.first?.isUppercase == true
        }.count

        return capitalizedCount >= 1 && capitalizedCount >= tokens.count / 2
    }

    private func searchAndMatch(titles: [String], mediaType: MediaType = .movie) async -> ImportResults {
        var matched: [MatchedMedia] = []
        var failed: [String] = []

        let totalTitles = titles.count
        var processedCount = 0

        for title in titles {
            do {
                // Search TMDb
                let results = try await apiService.searchMedia(query: title, page: 1, mediaType: mediaType)

                if let bestMatch = results.first {
                    matched.append(MatchedMedia(
                        title: title,
                        media: bestMatch,
                        confidence: calculateConfidence(original: title, matched: bestMatch.displayName)
                    ))
                } else {
                    failed.append(title)
                }
            } catch {
                failed.append(title)
            }

            processedCount += 1
            progress = 0.4 + (0.4 * Double(processedCount) / Double(totalTitles))
        }

        return ImportResults(matched: matched, failed: failed)
    }

    private func calculateConfidence(original: String, matched: String) -> Double {
        let originalLower = original.lowercased()
        let matchedLower = matched.lowercased()

        if originalLower == matchedLower {
            return 1.0
        }

        // Simple Levenshtein distance-based confidence
        let distance = levenshteinDistance(originalLower, matchedLower)
        let maxLength = max(originalLower.count, matchedLower.count)
        let similarity = 1.0 - (Double(distance) / Double(maxLength))

        return max(0, similarity)
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2Array.count + 1), count: s1Array.count + 1)

        for i in 0...s1Array.count {
            matrix[i][0] = i
        }

        for j in 0...s2Array.count {
            matrix[0][j] = j
        }

        for i in 1...s1Array.count {
            for j in 1...s2Array.count {
                if s1Array[i - 1] == s2Array[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = min(
                        matrix[i - 1][j] + 1,
                        matrix[i][j - 1] + 1,
                        matrix[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return matrix[s1Array.count][s2Array.count]
    }

    // MARK: - Batch Add

    func addMatchedToWatchlist(_ matches: [MatchedMedia], mediaType: MediaType, status: WatchStatus = .wantToWatch) {
        for match in matches {
            watchlistService.addToWatchlist(media: match.media, mediaType: mediaType, status: status)
        }
    }
}

// MARK: - Models

struct ImportResults {
    let matched: [MatchedMedia]
    let failed: [String]

    var successRate: Double {
        let total = matched.count + failed.count
        return total > 0 ? Double(matched.count) / Double(total) : 0
    }
}

struct MatchedMedia: Identifiable {
    let id = UUID()
    let title: String
    let media: Media
    let confidence: Double

    var confidenceColor: String {
        if confidence >= 0.9 {
            return "green"
        } else if confidence >= 0.7 {
            return "orange"
        } else {
            return "red"
        }
    }
}

enum ImportError: LocalizedError {
    case invalidImage
    case ocrFailed
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .ocrFailed:
            return "Failed to recognize text in image"
        case .noTextFound:
            return "No text found in image"
        }
    }
}
