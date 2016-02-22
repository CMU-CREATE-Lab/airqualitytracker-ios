//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: AirNowReadable, Hashable {
    
    
    // MARK: AirNowReadable/Hashable implementation
    
    
    private let readableType = ReadableType.ADDRESS
    var hashValue: Int { return generateHashForReadable() }
    var location: Location
    var airNowObservations: [AirNowObservation]
    
    
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    
    
    func hasReadableValue() -> Bool {
        if let feed = self.closestFeed {
            return feed.hasReadableValue()
        }
        return false
    }
    
    
    func getReadableValue() -> Double {
        if self.hasReadableValue() {
            // TODO nowcast testing?
            return self.closestFeed!.getReadableValue()
        }
        NSLog("Failed to get Readable Value on SimpleAddress; returning 0.0")
        return 0.0
    }
    
    
    func getName() -> String {
        return self.name
    }
    
    
    // MARK: class-specific definitions
    
    
    var _id: NSManagedObjectID?
    var positionId: Int?
    var name: String
    var zipcode: String
    var isCurrentLocation: Bool
    var closestFeed: Feed?
    var feeds: Array<Feed>
    let uid = 1
    
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        closestFeed = nil
        feeds = []
        isCurrentLocation = false
        airNowObservations = []
    }
    
}

// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}