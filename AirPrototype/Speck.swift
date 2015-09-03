//
//  Speck.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Speck: Feed {
    
    // Readable implementation

    private let readableType = ReadableType.SPECK
    override func getReadableType() -> ReadableType {
        return readableType
    }
    
    // class-specific definitions

    init(feed: Feed) {
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
    }
    
    // TODO add speck device-specific attributes
    
    func requestUpdate() {
        if self.channels.count > 0 {
            // TODO SettingsHandler
            HttpRequestHandler.sharedInstance.requestAuthorizedChannelReading("", feed: self, channel: self.channels[0])
        } else {
            NSLog("No channels found from speck id=\(self.feed_id)")
        }
    }
    
}