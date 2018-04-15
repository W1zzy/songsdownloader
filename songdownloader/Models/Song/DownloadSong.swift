//
//  DownloadSong.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

class DownloadSong {
    var song: Song

    init(song: Song) {
        self.song = song
    }
    
    var task: URLSessionDownloadTask?
    var progress: Float = 0
}
