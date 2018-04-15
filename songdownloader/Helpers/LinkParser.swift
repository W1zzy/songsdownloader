//
//  LinkParser.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

class LinkParser {
    static let audioFormats = ["aac","adts","ac3","aif","aiff","aifc","caf","mp3","mp4","m4a","snd","au","sd2","wav"]
    
    static func parseLink(_ url: URL?) throws -> SongSource {
        guard let url = url else {
            throw ParsingError.unknownFormat
        }
        
        if audioFormats.contains(url.pathExtension) {
            return SongSource(type: .directLink, url: url)
        }
        
        // Google Drive Links
        if let host = url.host, host.contains("drive.google.com") {
            let newUrl = try parseGoogleDriveLink(url)
            
            return SongSource(type: .googleDriveLink, url: newUrl)
        }
        
        throw ParsingError.parsingMethodNotFound
    }
    
    static func parseGoogleDriveLink(_ url: URL) throws -> URL {
        if let id = url["id"] {
            return try parseOpenFormatGoogleDriveLink(id)
        } else if url.absoluteString.contains("usp=sharing") {
            return try parseSharedFormatGoogleDriveLink(url)
        } else {
            throw ParsingError.unknownFormat
        }
    }
    
    static func parseOpenFormatGoogleDriveLink(_ id: String) throws -> URL {
        if let url = URL(string: "https://drive.google.com/uc?export=download&id=\(id)") {
            return url
        } else {
            throw ParsingError.unknownFormat
        }
    }
    
    static func parseSharedFormatGoogleDriveLink(_ url: URL) throws -> URL {
        do {
            let string = url.absoluteString
            let template = "https://drive.google.com/uc?export=download&confirm=no_antivirus&id=$1"
            
            let regex = try NSRegularExpression(pattern: "https://drive\\.google\\.com/file/d/(.*?)/.*?\\?usp=sharing", options: NSRegularExpression.Options())
            
            let result = regex.stringByReplacingMatches(in: string, options: [], range: NSMakeRange(0, string.count), withTemplate: template)
            
            if let url = URL(string: result) {
                return url
            } else {
                throw ParsingError.unknownFormat
            }
        } catch {
            throw ParsingError.unknownFormat
        }
    }
}
