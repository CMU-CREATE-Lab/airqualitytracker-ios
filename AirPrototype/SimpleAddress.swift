//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class SimpleAddress {
    
    enum IconType {
        case GPS, SPECK, DEFAULT
    }
    var _id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var closestFeed: Feed?
    var iconType: IconType
    
    init() {
        _id = -1
        name = ""
        latitude = 0
        longitude = 0
        iconType = IconType.DEFAULT
        closestFeed = nil
    }
}
