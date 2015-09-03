//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: Readable, Hashable {
    
    // Readable/Hashable implementation
    
    private let readableType = ReadableType.ADDRESS
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    func hasReadableValue() -> Bool {
        return self.closestFeed != nil
    }
    func getReadableValue() -> Double {
        if self.hasReadableValue() {
            return self.closestFeed!.feedValue
        }
        NSLog("Failed to get Readable Value on SimpleAddress; returning 0.0")
        return 0.0
    }
    func getName() -> String {
        return self.name
    }
    var hashValue: Int { return generateHashForReadable() }
    
    // class-specific definitions
    
    var _id: NSManagedObjectID?
    var name: String
    var zipcode: String
    var location: Location
    
    var closestFeed: Feed?
    var feeds: Array<Feed>
    let uid = 1
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        closestFeed = nil
        feeds = []
    }
    
    func requestUpdateFeeds() {
        // TODO Handle updating feeds asynchronously
        self.feeds.removeAll(keepCapacity: false)
    }
    
}

// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}