//
//  Readable.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

enum ReadableType {
    case ADDRESS, FEED, SPECK
}

protocol Readable {
    func getReadableType() -> ReadableType
    func getName() -> String
    func hasReadableValue() -> Bool
    func getReadableValue() -> Double
}
