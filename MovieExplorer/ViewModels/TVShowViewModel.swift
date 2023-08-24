//
//  TVShowViewModel.swift
//  MovieExplorer
//
//  Created by Dan Danilescu on 24.08.2023.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class TVShowListViewModel: ObservableObject {
    private let disposeBag = DisposeBag()
    private let apiKey = Constants.apiKey
    
    @Published var currentPage: Int = 1
    @Published var genreList: [Genre] = []
    @Published var mediaList: [Media] = []
    
    @Published var selectedGenreID: Int = 0 {
        didSet {
            print("Selected Genre ID: \(selectedGenreID)")
            currentPage = 1
            mediaList = []
            fetchMediaByGenre()
        }
    }
    @Published var mediaType: MediaType = .tv {
        didSet {
            print("Selected Media Type: \(mediaType)")
            currentPage = 1
            mediaList = []
            fetchMediaByGenre()
        }
    }
    
    init() {
        fetchGenreList()
    }
    
    func fetchGenreList() {
        let parameters: [String: Any] = [
            "api_key": apiKey
        ]
        
        let url = "https://api.themoviedb.org/3/genre/tv/list"
        
        AF.request(url, parameters: parameters)
            .responseDecodable(of: GenreListResponse.self) { response in
                switch response.result {
                case .success(let genreListResponse):
                    self.genreList = genreListResponse.genres
                    if let firstGenre = self.genreList.first {
                        self.selectedGenreID = firstGenre.id
                        self.fetchMediaByGenre()
                    }
                case .failure(let error):
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
        
        let url = "https://api.themoviedb.org/3/discover/tv"
        
        print("Fetching media for genre ID: \(selectedGenreID), media type: \(mediaType)")
        AF.request(url, parameters: parameters)
            .validate()
            .responseDecodable(of: MediaResponse.self) { response in
                switch response.result {
                case .success(let mediaResponse):
                    self.mediaList += mediaResponse.results
                case .failure(let error):
                    print("Error fetching media: \(error)")
                }
            }
    }
    
    func fetchDetails(for media: Media) {
        let detailsURL = "https://api.themoviedb.org/3/tv/\(media.id)"
        let parameters: [String: Any] = [
            "api_key": apiKey
        ]
        
        AF.request(detailsURL, parameters: parameters)
            .responseDecodable(of: MediaDetails.self) { response in
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
        currentPage += 1
        fetchMediaByGenre()
    }
    
    func refreshMediaList() {
         currentPage = 1
         mediaList = []
         fetchMediaByGenre()
     }
}
