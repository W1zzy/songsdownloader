//
//  ParsingError.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case unknownFormat
    case parsingMethodNotFound
}
