//
//  Feed.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Feed: Readable, Hashable {
    
    
    // MARK: Readable/Hashable implementation
    
    
    enum ReadableValueType {
        case INSTANTCAST, NOWCAST, NONE
    }
    
    private let readableType = ReadableType.FEED
    var readableValueType: ReadableValueType
    var hashValue: Int { return generateHashForReadable() }
    
    
    func setReadableValueType(type: ReadableValueType) {
        self.readableValueType = type
    }
    
    
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    
    
    func hasReadableValue() -> Bool {
        return self.readableValueType != ReadableValueType.NONE
    }
    
    
    func getReadableValue() -> Double {
        if hasReadableValue() {
            switch self.readableValueType {
            case ReadableValueType.INSTANTCAST:
                if let value = self.channels[0].instantcastValue {
                    return value
                }
            case ReadableValueType.NOWCAST:
                if let value = self.channels[0].nowcastValue {
                    return value
                }
            default:
                NSLog("ERROR - Could not detect ReadableValueType")
            }
        }
        return 0
    }
    
    
    func getName() -> String {
        return self.name
    }
    
    
    // MARK: class-specific definitions
    
    
    var feed_id: Int
    var name: String
    var exposure: String
    var isMobile: Bool
    var location: Location
    var productId: Int
    var channels: Array<Channel>
    var lastTime: Double
    
    
    init() {
        readableValueType = ReadableValueType.NONE
        feed_id = 0
        name = ""
        exposure = ""
        isMobile = false
        location = Location(latitude: 0, longitude: 0)
        productId = 0
        lastTime = 0
        channels = Array()
    }
    
}

// conforms to Equatable protocol
func == (lhs: Feed, rhs: Feed) -> Bool {
    return lhs.hashValue == rhs.hashValue
}