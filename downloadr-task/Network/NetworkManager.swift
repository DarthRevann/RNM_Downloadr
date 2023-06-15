//
//  NetworkManager.swift
//  downloadr-task
//
//  Created by Firuza Raiymkul on 15.06.2023.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()

    init() {}

    func getTracksFromVibze(completion: @escaping (Result<[PlayListViewController.Track], Error>) -> Void) {
        let url = "https://vibze.github.io/downloadr-task/tracks.json"

        AF.request(url).responseDecodable(of: [PlayListViewController.Track].self) { response in
            switch response.result {
            case .success(let tracks):
                completion(.success(tracks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
