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
        self.pm25Channels = feed.pm25Channels
        self.lastTime = feed.lastTime
    }
    
    
    func addChannel(_ channel: Channel) {
        if channel is Pm25Channel {
            pm25Channels.append(channel as! Pm25Channel)
        } else if channel is HumidityChannel {
            humidityChannels.append(channel as! HumidityChannel)
        } else if channel is TemperatureChannel {
            temperatureChannels.append(channel as! TemperatureChannel)
        }
    }
    
    
    func requestReadablePm25Reading() {
        if pm25Channels.count > 0 {
            let timeRange = Date().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
            let handler = GlobalHandler.sharedInstance.esdrFeedsHandler
            handler.requestChannelReading(nil, feedApiKey: self.apiKeyReadOnly!, feed: self, channel: self.pm25Channels.first!, maxTime: timeRange)
        } else {
            NSLog("ERROR - No PM25 channels found from speck id=\(self.feed_id)")
        }
    }
    
    
    func requestReadableHumidityReading() {
        if humidityChannels.count > 0 {
            let timeRange = Date().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
            let handler = GlobalHandler.sharedInstance.esdrFeedsHandler
            handler.requestChannelReading(nil, feedApiKey: self.apiKeyReadOnly!, feed: self, channel: self.humidityChannels.first!, maxTime: timeRange)
        } else {
            NSLog("ERROR - No Humidity channels found from speck id=\(self.feed_id)")
        }
    }
    
    
    func requestReadableTemperatureReading() {
        if temperatureChannels.count > 0 {
            let timeRange = Date().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
            let handler = GlobalHandler.sharedInstance.esdrFeedsHandler
            handler.requestChannelReading(nil, feedApiKey: self.apiKeyReadOnly!, feed: self, channel: self.temperatureChannels.first!, maxTime: timeRange)
        } else {
            NSLog("ERROR - No Temperature channels found from speck id=\(self.feed_id)")
        }
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
