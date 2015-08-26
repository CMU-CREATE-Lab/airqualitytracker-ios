//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: Hashable {
    
    static var hashId = 1
    static func generateHash() -> Int {
        return hashId++
    }
    var _id: NSManagedObjectID?
    var name: String
    var zipcode: String
    var latitude: Double
    var longitude: Double
    
    var closestFeed: Feed?
    let uid = 1
    var hashValue: Int { return SimpleAddress.generateHash() }
    
    init() {
        name = ""
        zipcode = ""
        latitude = 0
        longitude = 0
        closestFeed = nil
    }
}


// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}