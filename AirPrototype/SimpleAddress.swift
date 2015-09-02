//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: Hashable,Readable {
    
    // Readable implementation
    
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
    
    // class-specific definitions
    
    static var hashId = 1
    static func generateHash() -> Int {
        return hashId++
    }
    var _id: NSManagedObjectID?
    var name: String
    var zipcode: String
    var location: Location
    
    var closestFeed: Feed?
    let uid = 1
    var hashValue: Int { return SimpleAddress.generateHash() }
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        closestFeed = nil
    }
}


// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}