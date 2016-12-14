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

private var hashId = 1

func generateHashForReadable() -> Int {
    hashId = hashId + 1
    return hashId
}

// NOTICE
// the Readable protocol really should also inherit Hashable. However,
// due to the trash factor of Swift, you cannot reference a protocol
// as a constraint if it has a reference to "Self" in its definition.
// In this case, Hashable inherits Equatable, which uses Self.
//
// tl;dr: when classes inherit Readable, inherit Hashable as well.
//protocol Readable: Hashable {
protocol Readable {
    
    // ASSERT: this should return generateHashForReadable()
    var hashValue: Int { get }
    
    func getReadableType() -> ReadableType
    func getName() -> String
    func hasReadableValue() -> Bool
    func getReadableValue() -> Double
    
}
