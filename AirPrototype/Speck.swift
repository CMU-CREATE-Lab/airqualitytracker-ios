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
    
    
    // MARK: Readable implementation
    

    private let readableType = ReadableType.SPECK
    
    
    override func getReadableType() -> ReadableType {
        return readableType
    }
    
    
    // MARK: class-specific definitions
    
    
    var _id: NSManagedObjectID?
    var deviceId: Int
    var positionId: Int?
    var apiKeyReadOnly: String?
    
    
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
        self.lastTime = feed.lastTime
    }
    
}