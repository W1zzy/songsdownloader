//
//  NetworkManager.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import UIKit

class NetworkManager {
    private lazy var session: URLSession = URLSession(configuration: .default)
    
    static let shared = NetworkManager()
    private init() {}
    
    private let timeout = 30
    
    func dataTask(with request: URLRequest, completion: @escaping (Data) -> Void, failure: @escaping (String) -> Void) {
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil {
                failure(error?.localizedDescription ?? "Something went wrong")
            } else {
                if let data = data {
                    completion(data)
                } else {
                    failure("Wrong data received")
                }
            }
        })
        
        task.resume()
    }
}
