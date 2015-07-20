//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class SimpleAddress: Hashable {
    
    static var hashId = 1
    static func generateHash() -> Int {
        return hashId++
    }
    enum IconType {
        case GPS, SPECK, DEFAULT
    }
    var _id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var closestFeed: Feed?
    var iconType: IconType
    let uid = 1
    var hashValue: Int { return SimpleAddress.generateHash() }
    
    init() {
        _id = -1
        name = ""
        latitude = 0
        longitude = 0
        iconType = IconType.DEFAULT
        closestFeed = nil
    }
}


// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}