//
//  SongsJsonObject.swift
//  songdownloader
//
//  Created by Антон Братчик on 13.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

struct SongsData: Codable {
    let songs: [Song]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        songs = try values.decode([Song].self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(songs, forKey: .data)
    }
}
