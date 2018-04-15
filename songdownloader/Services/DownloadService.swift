//
//  DownloadService.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

class DownloadService {
    var downloadsSession: URLSession!
    var activeDownloads: [URL: DownloadSong] = [:]
    
    func startDownload(_ song: Song, failure: @escaping () -> Void) {
        if let songURL = song.audioURL, let source = try? LinkParser.parseLink(songURL) {
            switch (source.type) {
            case .directLink:
                let download = DownloadSong(song: song)
                
                download.task = downloadsSession.downloadTask(with: source.url)
                download.task?.resume()
                
                // songURL uses for identifier song
                activeDownloads[songURL] = download
            case .googleDriveLink:
                NetworkManager.shared.getSongMetadata(url: source.url, completion: { [weak self] (data) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    // replacing broken part of JSON
                    let dataString = String(data: data, encoding:String.Encoding.utf8)?.replacingOccurrences(of: ")]}'", with: "")
                    
                    // we need only size and direct link from metadata
                    if let cleanData = dataString?.data(using: String.Encoding.utf8), let json = try? JSONSerialization.jsonObject(with: cleanData, options: .allowFragments) as? [String: AnyObject], let directLinkString = json?["downloadUrl"] as? String, let directLink = URL(string: directLinkString) {
                        let size = json?["sizeBytes"] as? Int64
                        
                        var songWithSize = song
                        songWithSize.fileSize = size ?? 0
                        
                        let download = DownloadSong(song: songWithSize)
                        
                        download.task = strongSelf.downloadsSession.downloadTask(with: directLink)
                        download.task?.resume()
                        
                        // songURL uses for identifier song
                        strongSelf.activeDownloads[directLink] = download
                    } else {
                        failure()
                    }
                }) { (error) in
                    // nothing to do here
                    failure()
                }
            }
        } else {
            failure()
        }
    }
    
}
