//
//  Feed.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Feed: Readable {
    
    // Readable implementation

    private let readableType = ReadableType.FEED
    private var feedHasReadableValue: Bool
    func setHasReadableValue(hasReadableValue: Bool) {
        self.feedHasReadableValue = hasReadableValue
    }
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    func hasReadableValue() -> Bool {
        return self.feedHasReadableValue
    }
    func getReadableValue() -> Double {
        return self.feedValue
    }
    func getName() -> String {
        return self.name
    }
    
    // class-specific definitions
    
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
        feedHasReadableValue = false
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