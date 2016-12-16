//
//  Speck.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class Speck: Pm25Feed, HumidityReadable, TemperatureReadable {
    
    
    // MARK: class-specific definitions
    
    
    var _id: NSManagedObjectID?
    var deviceId: Int
    var positionId: Int?
    var apiKeyReadOnly: String?
    
    
    init(feed: Pm25Feed, deviceId: Int) {
        self.deviceId = deviceId
        super.init()
        
        self.feed_id = feed.feed_id
        self.name = feed.name
        self.exposure = feed.exposure
        self.isMobile = feed.isMobile
        self.location = feed.location
        self.productId = feed.productId
//        self.channels = feed.channels
        self.pm25Channels = feed.pm25Channels
        self.lastTime = feed.lastTime
    }
    
    
    func addChannel(channel: Channel) {
        // TODO actions
    }
    
    
    // HumidityReadable implementation
    
    
    var readableHumidityValue: ReadableValue?
    var humidityChannels = Array<HumidityChannel>()
    
    
    func getHumidityChannels() -> Array<HumidityChannel> {
        return humidityChannels
    }
    
    
    func hasReadableHumidityValue() -> Bool {
        return (readableHumidityValue != nil)
    }
    
    
    func getReadableHumidityValue() -> ReadableValue {
        return readableHumidityValue!
    }
    
    
    // TemperatureReadable implementation

    
    var readableTemperatureValue: ReadableValue?
    var temperatureChannels = Array<TemperatureChannel>()
    
    
    func getTemperatureChannels() -> Array<TemperatureChannel> {
        return temperatureChannels
    }
    
    
    func hasReadableTemperatureValue() -> Bool {
        return (readableTemperatureValue != nil)
    }
    
    
    func getReadableTemperatureValue() -> ReadableValue {
        return readableTemperatureValue!
    }
    
}
