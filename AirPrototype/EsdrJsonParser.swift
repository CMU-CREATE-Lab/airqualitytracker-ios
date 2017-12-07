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
        
        if let channels = (dataEntry.value(forKey: "channelBounds") as AnyObject).value(forKey: "channels") as? NSDictionary {
            let keys = channels.keyEnumerator()
            while let channelName = keys.nextObject() as? String {
//                // Only grab channels that we care about
//                if let index = Constants.channelNames.indexOf(channelName) {
//                    // ... now we grab them all
//                }
                // NOTICE: we must also make sure that this specific channel was updated
                // in the past 24 hours ("maxTime").
                let channel = channels.value(forKey: channelName) as! NSDictionary
                let channelTime = channel.value(forKey: "maxTimeSecs") as! Double
                if channelTime >= maxTime {
//                    feedChannels.append(parseChannelFromJson(channelName, feed: result, dataEntry: channel))
                    result.addChannel(parseChannelFromJson(channelName, feed: result, dataEntry: channel))
                    //break
                }
            }
//            result.channels = feedChannels
        }
        
        return result
    }
    
    
    static func parseChannelFromJson(_ channelName: String, feed: Pm25Feed, dataEntry: NSDictionary) -> Channel {
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
