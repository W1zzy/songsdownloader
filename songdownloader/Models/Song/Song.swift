//
//  Song.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

struct Song: Codable {
    let id                : Int?
    let name              : String?
    let audioURL          : URL?
    
    var localURL          : URL? // local path to audio file
    private(set) var state: SongViewState = .none // state of datasource item
    var downloaded                        = false
    var fileSize          : Int64         = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case audioURL
        case downloaded
        case localURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        audioURL   = URL(string: try container.decode(String.self, forKey: .audioURL))
        name       = try container.decode(String.self, forKey: .name)
        id         = Int(try container.decode(String.self, forKey: .id))
        downloaded = (try? container.decode(Bool.self, forKey: .downloaded)) ?? false
        
        if let localURLString = try? container.decode(String.self, forKey: .localURL) {
            localURL   = URL(string: localURLString)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(audioURL, forKey: .audioURL)
        try container.encode(name, forKey: .name)
        
        if let id = id {
            try container.encode("\(id)", forKey: .id)
        }
        
        try container.encode(downloaded, forKey: .downloaded)
        
        if let localURLString = localURL?.absoluteString {
            try container.encode(localURLString, forKey: .localURL)
        }
    }
    
    mutating func changeState() {
        switch state {
        case .none:
            state = .downloading
        case .downloading:
            state = .pause
        case .play:
            state = .pause
        case .pause:
            state = .play
        }
    }
    
    mutating func resetState() {
        state = .none
    }
    
    mutating func recognizeState() {
        if downloaded {
            state = .pause
        } else {
            state = .none
        }
    }
}

extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}

