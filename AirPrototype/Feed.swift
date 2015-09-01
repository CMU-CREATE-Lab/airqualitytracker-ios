//
//  Feed.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Feed {
    var feed_id: Int
    var name: String
    var exposure: String
    var isMobile: Bool
    var location: Location
    var productId: Int
    var channels: Array<Channel>
    var feedValue: Double
    var lastTime: Double
    
    init() {
        feed_id = 0
        name = ""
        exposure = ""
        isMobile = false
        location = Location(latitude: 0, longitude: 0)
        productId = 0
        feedValue = 0
        lastTime = 0
        channels = Array()
    }
}