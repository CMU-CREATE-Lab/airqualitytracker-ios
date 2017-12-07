//
//  AirQualityFeed.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class AirQualityFeed: Pm25Feed, OzoneReadable {
    
    var readableOzoneValue: AqiReadableValue?
    var ozoneChannels = Array<OzoneChannel>()
    var simpleAddress: SimpleAddress?
    
    
    func addChannel(_ channel: Channel) {
        if (channel is Pm25Channel) {
            pm25Channels.append(channel as! Pm25Channel)
        } else if (channel is OzoneChannel) {
            ozoneChannels.append(channel as! OzoneChannel)
        } else {
            NSLog("WARNING - could not add channel to AirQualityFeed: name=\(channel.name)")
        }
        channel.feed = self
    }
    
    
    // OzoneReadable implementation
    
    
    func getOzoneChannels() -> Array<OzoneChannel> {
        return ozoneChannels
    }
    
    
    func hasReadableOzoneValue() -> Bool {
        return (readableOzoneValue != nil)
    }
    
    
    func getReadableOzoneValue() -> AqiReadableValue {
        return readableOzoneValue!
    }
    
    
    // Readable Implementation
    
    
    fileprivate func generateReadableValues() -> Array<ReadableValue> {
        var result = Array<ReadableValue>()
        if (hasReadablePm25Value()) {
            result.append(self.readablePm25Value!)
        }
        if (hasReadableOzoneValue()) {
            result.append(self.readableOzoneValue!)
        }
        return result
    }
    
    
    override func hasReadableValue() -> Bool {
        return (generateReadableValues().count > 0)
    }
    
    
    override func getReadableValues() -> Array<ReadableValue> {
        return generateReadableValues()
    }
    
}
