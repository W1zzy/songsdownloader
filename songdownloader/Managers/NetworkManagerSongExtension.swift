//
//  NetworkManagerSongExtension.swift
//  songdownloader
//
//  Created by Антон Братчик on 13.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

extension NetworkManager {
    func getSongsList(completion: @escaping (Data) -> Void, failure: @escaping (String) -> Void) {
        if let url = URL(string: ApiEndpoints.songsListURL) {
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            
            dataTask(with: request, completion: { (data) in
                completion(data)
            }, failure: { (error) in
                failure(error)
            })
        } else {
            failure("Song list unavailable, try again later")
        }
    }
    
    // Google Drive
    func getSongMetadata(url: URL, completion: @escaping (Data) -> Void, failure: @escaping (String) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // hardcoded headers for getting metadata without API Framework and authorisation via REST api
        request.addValue("true", forHTTPHeaderField: "x-json-requested")
        request.addValue("DriveWebUi", forHTTPHeaderField: "x-drive-first-party")
        
        dataTask(with: request, completion: { (data) in
            completion(data)
        }, failure: { (error) in
            failure(error)
        })
    }
}
