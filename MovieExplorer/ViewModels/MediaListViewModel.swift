//
//  MediaListViewModel.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import Alamofire

class MediaListViewModel: ObservableObject {
    private let apiKey = Constants.apiKey
    let mediaType: MediaType

    @Published var currentPage: Int = 1
    @Published var genreList: [Genre] = []
    @Published var mediaList: [Media] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var selectedGenreID: Int = 0 {
        didSet {
            print("Selected Genre ID: \(selectedGenreID)")
            currentPage = 1
            mediaList = []
            fetchMediaByGenre()
        }
    }

    init(mediaType: MediaType) {
        self.mediaType = mediaType
        fetchGenreList()
    }

    func fetchGenreList() {
        let parameters: [String: Any] = [
            "api_key": apiKey
        ]

        let url = Constants.API.genreListURL(for: mediaType)

        isLoading = true
        errorMessage = nil

        AF.request(url, parameters: parameters)
            .responseDecodable(of: GenreListResponse.self) { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false

                switch response.result {
                case .success(let genreListResponse):
                    self.genreList = genreListResponse.genres
                    if let firstGenre = self.genreList.first {
                        self.selectedGenreID = firstGenre.id
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load genres: \(error.localizedDescription)"
                    print("Error fetching genre list: \(error)")
                }
            }
    }

    func fetchMediaByGenre() {
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "with_genres": selectedGenreID,
            "page": currentPage
        ]

        let url = Constants.API.discoverURL(for: mediaType)

        isLoading = true
        errorMessage = nil

        print("Fetching media for genre ID: \(selectedGenreID), media type: \(mediaType)")
        AF.request(url, parameters: parameters)
            .validate()
            .responseDecodable(of: MediaResponse.self) { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false

                switch response.result {
                case .success(let mediaResponse):
                    self.mediaList += mediaResponse.results
                case .failure(let error):
                    self.errorMessage = "Failed to load \(self.mediaType == .movie ? "movies" : "TV shows"): \(error.localizedDescription)"
                    print("Error fetching media: \(error)")
                }
            }
    }

    func fetchDetails(for media: Media) {
        let detailsURL = Constants.API.detailsURL(for: mediaType, id: media.id)
        let parameters: [String: Any] = [
            "api_key": apiKey
        ]

        AF.request(detailsURL, parameters: parameters)
            .responseDecodable(of: MediaDetails.self) { [weak self] response in
                guard let self = self else { return }

                switch response.result {
                case .success(let details):
                    if let index = self.mediaList.firstIndex(where: { $0.id == media.id }) {
                        self.mediaList[index].details = details
                    }
                case .failure(let error):
                    print("Error fetching media details: \(error)")
                }
            }
    }

    func loadMoreData() {
        guard !isLoading else { return }
        currentPage += 1
        fetchMediaByGenre()
    }

    func refreshMediaList() {
        currentPage = 1
        mediaList = []
        fetchMediaByGenre()
    }
}
