//
//  TMDBAPIServiceProtocol.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation

protocol TMDBAPIServiceProtocol: Actor {
    func fetchGenres(for mediaType: MediaType) async throws -> [Genre]
    func discoverMedia(genreID: Int, page: Int, mediaType: MediaType) async throws -> [Media]
    func fetchMediaDetails(id: Int, mediaType: MediaType) async throws -> MediaDetails
    func searchMedia(query: String, page: Int, mediaType: MediaType) async throws -> [Media]
}

extension TMDBAPIService: TMDBAPIServiceProtocol {}
