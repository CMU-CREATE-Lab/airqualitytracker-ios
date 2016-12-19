//
//  Pm25Feed.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class Pm25Feed: Feed, Pm25Readable {
    
    // class attributes
    var readablePm25Value: AqiReadableValue?
    var pm25Channels = Array<Pm25Channel>()
    var feed_id = Int()
    var name = String()
    var exposure = String()
    var isMobile = false
    var location = Location(latitude: 0, longitude: 0)
    var productId = 0
    var lastTime = Double()
    
    
    // Pm25Readable implementation
    
    
    func getPm25Channels() -> Array<Pm25Channel> {
        return pm25Channels
    }
    
    
    func hasReadablePm25Value() -> Bool {
        return (readablePm25Value != nil)
    }
    
    
    func getReadablePm25Value() -> AqiReadableValue {
        return readablePm25Value!
    }
    
    
    // Readable Implementation
    
    
    func hasReadableValue() -> Bool {
        return (readablePm25Value != nil)
    }
    
    
    func getReadableValues() -> Array<ReadableValue> {
        var result = Array<ReadableValue>()
        if (hasReadableValue()) {
            result.append(readablePm25Value!)
        }
        return result
    }

}

// conforms to Equatable protocol
func == (lhs: Pm25Feed, rhs: Pm25Feed) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
