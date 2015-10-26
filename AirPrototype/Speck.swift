//
//  Speck.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class Speck: Feed {
    
    // Readable implementation

    private let readableType = ReadableType.SPECK
    override func getReadableType() -> ReadableType {
        return readableType
    }
    
    // class-specific definitions

    init(feed: Feed, deviceId: Int) {
        self.deviceId = deviceId
        super.init()
        
        self.feed_id = feed.feed_id
        self.name = feed.name
        self.exposure = feed.exposure
        self.isMobile = feed.isMobile
        self.location = feed.location
        self.productId = feed.productId
        self.channels = feed.channels
        self.feedValue = feed.feedValue
        self.lastTime = feed.lastTime
        NSLog("Constructed a new Speck! name=\(name), location=\(location), feedValue=\(feedValue)")
    }
    
    var _id: NSManagedObjectID?
    var deviceId: Int
    var positionId: Int?
    
    func requestUpdate() {
        if self.channels.count > 0 {
            if let accessToken = SettingsHandler.sharedInstance.accessToken {
                HttpRequestHandler.sharedInstance.requestAuthorizedChannelReading(accessToken, feed: self, channel: self.channels[0])
            } else {
                NSLog("WARNING - could not request channel reading for Speck=\(name); accessToken is nil.")
            }
        } else {
            NSLog("No channels found from speck id=\(self.feed_id)")
        }
    }
    
}