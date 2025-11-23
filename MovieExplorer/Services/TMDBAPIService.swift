//
//  TMDBAPIService.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import Alamofire

enum APIError: LocalizedError {
    case networkError(Error)
    case invalidAPIKey
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .decodingError:
            return "Failed to decode response. The data format may have changed."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

actor TMDBAPIService {
    private let apiKey: String

    init(apiKey: String = Constants.apiKey) {
        self.apiKey = apiKey
    }

    // MARK: - Genre Endpoints

    func fetchGenres(for mediaType: MediaType) async throws -> [Genre] {
        let url = Constants.API.genreListURL(for: mediaType)
        let parameters: [String: Any] = ["api_key": apiKey]

        do {
            let response = try await AF.request(url, parameters: parameters)
                .validate()
                .serializingDecodable(GenreListResponse.self)
                .value
            return response.genres
        } catch let afError as AFError {
            throw mapAFError(afError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Discover Endpoints

    func discoverMedia(
        genreID: Int,
        page: Int,
        mediaType: MediaType
    ) async throws -> [Media] {
        let url = Constants.API.discoverURL(for: mediaType)
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "with_genres": genreID,
            "page": page
        ]

        do {
            let response = try await AF.request(url, parameters: parameters)
                .validate()
                .serializingDecodable(MediaResponse.self)
                .value
            return response.results
        } catch let afError as AFError {
            throw mapAFError(afError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Details Endpoints

    func fetchMediaDetails(id: Int, mediaType: MediaType) async throws -> MediaDetails {
        let url = Constants.API.detailsURL(for: mediaType, id: id)
        let parameters: [String: Any] = ["api_key": apiKey]

        do {
            let response = try await AF.request(url, parameters: parameters)
                .validate()
                .serializingDecodable(MediaDetails.self)
                .value
            return response
        } catch let afError as AFError {
            throw mapAFError(afError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Search Endpoints

    func searchMedia(
        query: String,
        page: Int,
        mediaType: MediaType
    ) async throws -> [Media] {
        let baseURL = Constants.API.baseURL
        let url = "\(baseURL)/search/\(mediaType == .movie ? "movie" : "tv")"
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "query": query,
            "page": page
        ]

        do {
            let response = try await AF.request(url, parameters: parameters)
                .validate()
                .serializingDecodable(MediaResponse.self)
                .value
            return response.results
        } catch let afError as AFError {
            throw mapAFError(afError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Error Mapping

    private func mapAFError(_ error: AFError) -> APIError {
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                if code == 401 {
                    return .invalidAPIKey
                }
                return .serverError(statusCode: code)
            }
            return .networkError(error)
        case .responseSerializationFailed:
            return .decodingError(error)
        default:
            return .networkError(error)
        }
    }
}
