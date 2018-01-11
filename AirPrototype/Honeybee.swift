//
//  Honeybee.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 12/14/17.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class Honeybee: Feed, LargeParticleReadable, SmallParticleReadable {
    
    var _id: NSManagedObjectID?
    var feed_id = Int()
    var name = String()
    var exposure = String()
    var isMobile = false
    var location = Location(latitude: 0, longitude: 0)
    var productId = 0
    var lastTime = Double()
    var deviceId: Int
    var positionId: Int?
    var apiKeyReadOnly: String?
    
    
    init(deviceId: Int) {
        self.deviceId = deviceId
    }
    
    
    func addChannel(channel: Channel) {
        if (channel is LargeParticleChannel) {
            largeParticleChannels.append(channel as! LargeParticleChannel)
        } else if (channel is SmallParticleChannel) {
            smallParticleChannels.append(channel as! SmallParticleChannel)
        } else {
            NSLog("cannot add channel to Honeybee (class not recognized)")
        }
    }
    
    
    func requestReadableLargeParticleReading() {
        if largeParticleChannels.count > 0 {
            let handler = GlobalHandler.sharedInstance.esdrFeedsHandler
            handler.requestChannelReadingForHoneybee(feedApiKey: self.apiKeyReadOnly!, honeybee: self, channel: self.largeParticleChannels.first!, maxTime: nil)
        } else {
            NSLog("ERROR - No LargeParticle channels found from honeybee id=\(self.feed_id)")
        }
    }
    
    
    func requestReadableSmallParticleReading() {
        if smallParticleChannels.count > 0 {
            let handler = GlobalHandler.sharedInstance.esdrFeedsHandler
            handler.requestChannelReadingForHoneybee(feedApiKey: self.apiKeyReadOnly!, honeybee: self, channel: self.smallParticleChannels.first!, maxTime: nil)
        } else {
            NSLog("ERROR - No LargeParticle channels found from honeybee id=\(self.feed_id)")
        }
    }
    
    
    func getLargeParticleChannels() -> Array<LargeParticleChannel> {
        return largeParticleChannels
    }
    
    
    func getSmallParticleChannels() -> Array<SmallParticleChannel> {
        return smallParticleChannels
    }
    
    
    // LargeParticleReadable
    
    var readableLargeParticleValue: ReadableValue?
    var largeParticleChannels = Array<LargeParticleChannel>()
    
    
    func hasReadableLargeParticleValue() -> Bool {
        return (readableLargeParticleValue != nil)
    }
    
    
    func getReadableLargeParticleValue() -> ReadableValue {
        return readableLargeParticleValue!
    }
    
    
    // SmallParticleReadable
    
    var readableSmallParticleValue: ReadableValue?
    var smallParticleChannels = Array<SmallParticleChannel>()
    
    
    func hasReadableSmallParticleValue() -> Bool {
        return (readableSmallParticleValue != nil)
    }
    
    
    func getReadableSmallParticleValue() -> ReadableValue {
        return readableSmallParticleValue!
    }
    
    
    // Readable Implementation
    
    
    func hasReadableValue() -> Bool {
        return (readableSmallParticleValue != nil)
    }
    
    
    func getReadableValues() -> Array<ReadableValue> {
        var result = Array<ReadableValue>()
        if (hasReadableValue()) {
            result.append(readableSmallParticleValue!)
        }
        return result
    }

}

// conforms to Equatable protocol
func == (lhs: Honeybee, rhs: Honeybee) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
