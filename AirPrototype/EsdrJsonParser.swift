//
//  EsdrJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 7/22/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class EsdrJsonParser {
    
    
    static func formatSafeJson(_ json: NSString) -> NSString {
        var result = json
        
        // remove occurences of strings that break json parser (ex: -1e+308=>0)
        result = result.replacingOccurrences(of: "-1e+308", with: "0") as NSString
        
        return result
    }
    
    
    static func populateFeedsFromJson(_ data: NSDictionary, simpleAddress: SimpleAddress, maxTime: Double) -> [AirQualityFeed] {
        var feeds = Array<AirQualityFeed>()
        if let rows = (data.value(forKey: "data") as! NSDictionary).value(forKey: "rows") as? Array<NSDictionary> {
            for row in rows {
                let feed = parseFeedFromJson(row, maxTime: maxTime)
                // only consider non-null feeds with at least 1 channel
                // TODO save more than just PM25?
                if feed.getPm25Channels().count > 0 {
                    feeds.append(feed)
                    feed.simpleAddress = simpleAddress
                }
            }
        }
        return feeds
    }
    
    
    static func populateSpecksFromJson(_ data: NSDictionary) -> [Speck] {
        var specks = Array<Speck>()
        if let rows = (data.value(forKey: "data") as! NSDictionary).value(forKey: "rows") as? Array<NSDictionary> {
            for row in rows {
                // TODO this needs its own function or else you won't call addChannel() properly
                let feed = parseFeedFromJson(row, maxTime: 0)
                // only consider non-null feeds with at least 1 channel
//                if feed.channels.count > 0 {
                if feed.pm25Channels.count > 0 {
                    let deviceId = row.value(forKey: "deviceId") as! Int
                    let apiKeyReadOnly = row.value(forKey: "apiKeyReadOnly") as! String
                    let speck = Speck(feed: feed, deviceId: deviceId)
                    speck.apiKeyReadOnly = apiKeyReadOnly
                    specks.append(speck)
                }
            }
        }
        return specks
    }
    
    
    fileprivate static func parseChannelsFromFeed(_ feed: Pm25Feed?, dataEntry: NSDictionary, maxTime: Double) -> [Channel] {
        var result = [Channel]()
        
        if let channels = (dataEntry.value(forKey: "channelBounds") as AnyObject).value(forKey: "channels") as? NSDictionary {
            // actions
            let keys = channels.keyEnumerator()
            while let channelName = keys.nextObject() as? String {
                let channel = channels.value(forKey: channelName) as! NSDictionary
                let channelTime = channel.value(forKey: "maxTimeSecs") as! Double
                if channelTime >= maxTime {
                    result.append(parseChannelFromJson(channelName, feed: feed, dataEntry: channel))
                }
            }

        }
        
        return result
    }
    
    
    static func populateHoneybeesFromJson(_ data: NSDictionary) -> [Honeybee] {
        var honeybees = Array<Honeybee>()
        if let rows = (data.value(forKey: "data") as! NSDictionary).value(forKey: "rows") as? Array<NSDictionary> {
            for row in rows {
                // only consider non-null feeds with at least 1 channel
                //                if feed.channels.count > 0 {
                let channels = parseChannelsFromFeed(nil, dataEntry: row, maxTime: 0)
                if channels.count > 0 {
                    let feed_id = row.value(forKey: "id") as! Int
                    let name = row.value(forKey: "name") as! String
                    let exposure = row.value(forKey: "exposure") as! String
                    let isMobile = row.value(forKey: "isMobile") as! Int
                    let latitude = row.value(forKey: "latitude") as? Double
                    let longitude = row.value(forKey: "longitude") as? Double
                    let productId = row.value(forKey: "productId") as! Int
                    
                    let honeybee = Honeybee(deviceId: row.value(forKey: "deviceId") as! Int)
                    honeybee.apiKeyReadOnly = row.value(forKey: "apiKeyReadOnly") as! String
                    honeybee.feed_id = feed_id
                    honeybee.name = name
                    honeybee.exposure = exposure
                    honeybee.isMobile = isMobile == 1
                    if latitude != nil && longitude != nil {
                        honeybee.location.latitude = latitude!
                        honeybee.location.longitude = longitude!
                    } else {
                        honeybee.location.latitude = 0
                        honeybee.location.longitude = 0
                    }
                    honeybee.productId = productId
                    
                    for channel in channels {
                        honeybee.addChannel(channel: channel)
                    }
                    
                    honeybees.append(honeybee)
                }
            }
        }
        return honeybees
    }
    
    
    static func parseFeedFromJson(_ dataEntry: NSDictionary, maxTime: Double) -> AirQualityFeed {
        let result = AirQualityFeed()
//        var feedChannels = Array<Channel>()
        
        let feed_id = dataEntry.value(forKey: "id") as! Int
        let name = dataEntry.value(forKey: "name") as! String
        let exposure = dataEntry.value(forKey: "exposure") as! String
        let isMobile = dataEntry.value(forKey: "isMobile") as! Int
        let latitude = dataEntry.value(forKey: "latitude") as? Double
        let longitude = dataEntry.value(forKey: "longitude") as? Double
        let productId = dataEntry.value(forKey: "productId") as! Int
        
        result.feed_id = feed_id
        result.name = name
        result.exposure = exposure
        result.isMobile = isMobile == 1
        if latitude != nil && longitude != nil {
            result.location.latitude = latitude!
            result.location.longitude = longitude!
        } else {
            result.location.latitude = 0
            result.location.longitude = 0
        }
        result.productId = productId
        
        let channels = parseChannelsFromFeed(result, dataEntry: dataEntry, maxTime: maxTime)
        if channels.count > 0 {
            for channel in channels {
                result.addChannel(channel)
            }
        }
        
        return result
    }
    
    
    static func parseChannelFromJson(_ channelName: String, feed: Pm25Feed?, dataEntry: NSDictionary) -> Channel {
        var channel: Channel
        
        // check for known channel types
        if (Constants.channelNamesPm.contains(channelName)) {
            channel = Pm25Channel()
            NSLog("new Pm25Channel \(channelName)")
        } else if (Constants.channelNamesOzone.contains(channelName)) {
            channel = OzoneChannel()
            NSLog("new OzoneChannel \(channelName)")
        } else if (Constants.channelNamesHumidity.contains(channelName)) {
            channel = HumidityChannel()
            NSLog("new HumidityChannel \(channelName)")
        } else if (Constants.channelNamesTemperature.contains(channelName)) {
            channel = TemperatureChannel()
            NSLog("new TemperatureChannel \(channelName)")
        } else if (Constants.channelNamesLargeParticles.contains(channelName)) {
            channel = LargeParticleChannel()
            NSLog("new LargeParticleChannel \(channelName)")
        } else if (Constants.channelNamesSmallParticles.contains(channelName)) {
            channel = SmallParticleChannel()
            NSLog("new SmallParticleChannel \(channelName)")
        } else {
            channel = Channel()
            NSLog("General Channel created from channelName=\(channelName)")
        }
        
        let minTimeSecs = dataEntry.value(forKey: "minTimeSecs") as! Double
        let maxTimeSecs = dataEntry.value(forKey: "maxTimeSecs") as! Double
        let minValue = dataEntry.value(forKey: "minValue") as! Double
        let maxValue = dataEntry.value(forKey: "maxValue") as! Double
        
        channel.name = channelName
        channel.feed = feed
        channel.minTimeSecs = minTimeSecs
        channel.maxTimeSecs = maxTimeSecs
        channel.minValue = minValue
        channel.maxValue = maxValue
        
        return channel
    }
    
    
    static func parseTiles(_ dataEntry: NSDictionary, fromTime: Int, toTime: Int) -> [Int: [Double]] {
        var results: [Int: [Double]]
        results = [Int: [Double]]()
        
        // grab all tiles within timestamp range (fromTime..toTime)
        let data = dataEntry.value(forKey: "data") as! NSDictionary
        let innerData = data.value(forKey: "data") as! Array<Array<Any>>
        for point in innerData {
            let time = Int(point[0] as! NSNumber)
            if time > fromTime && time <= toTime {
                let mean = point[1] as! NSNumber
                let count = point[3] as! NSNumber
                results[time] = [Double(mean),Double(count)]
            }
        }
        return results
    }
    
    
    static func parseDailyFeedTracker(_ feed: Pm25Feed, from: Int, to: Int, dataEntry: NSDictionary) -> DailyFeedTracker {
        let result = DailyFeedTracker(feed: feed, from: from, to: to)
        
        let data = dataEntry.value(forKey: "data") as! Array<Array<Any>>
        for row in data {
            // ASSERT: request was done in the order: mean, median, max
            let time = row[0] as! Int
            let mean = row[1] as! Double
            let median = row[2] as! Double
            let max = row[3] as! Double
            
            result.values.append(DayFeedValue(time: time, mean: mean, median: median, max: max))
        }
        
        return result
    }
    
}
