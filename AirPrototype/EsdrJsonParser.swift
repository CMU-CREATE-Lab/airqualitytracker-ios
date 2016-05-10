//
//  EsdrJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 7/22/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class EsdrJsonParser {
    
    
    static func populateFeedsFromJson(data: NSDictionary, maxTime: Double) -> [Feed] {
        var feeds = Array<Feed>()
        if let rows = (data.valueForKey("data") as! NSDictionary).valueForKey("rows") as? Array<NSDictionary> {
            for row in rows {
                let feed = parseFeedFromJson(row, maxTime: maxTime)
                // only consider non-null feeds with at least 1 channel
                if feed.channels.count > 0 {
                    feeds.append(feed)
                }
            }
        }
        return feeds
    }
    
    
    static func populateSpecksFromJson(data: NSDictionary) -> [Speck] {
        var specks = Array<Speck>()
        if let rows = (data.valueForKey("data") as! NSDictionary).valueForKey("rows") as? Array<NSDictionary> {
            for row in rows {
                let feed = parseFeedFromJson(row, maxTime: 0)
                // only consider non-null feeds with at least 1 channel
                if feed.channels.count > 0 {
                    let deviceId = row.valueForKey("deviceId") as! Int
                    let apiKeyReadOnly = row.valueForKey("apiKeyReadOnly") as! String
                    let speck = Speck(feed: feed, deviceId: deviceId)
                    speck.apiKeyReadOnly = apiKeyReadOnly
                    specks.append(speck)
                }
            }
        }
        return specks
    }
    
    
    static func parseFeedFromJson(dataEntry: NSDictionary, maxTime: Double) -> Feed {
        let result = Feed()
        var feedChannels = Array<Channel>()
        
        let feed_id = dataEntry.valueForKey("id") as! Int
        let name = dataEntry.valueForKey("name") as! String
        let exposure = dataEntry.valueForKey("exposure") as! String
        let isMobile = dataEntry.valueForKey("isMobile") as! Int
        let latitude = dataEntry.valueForKey("latitude") as? Double
        let longitude = dataEntry.valueForKey("longitude") as? Double
        let productId = dataEntry.valueForKey("productId") as! Int
        
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
        
        if let channels = dataEntry.valueForKey("channelBounds")?.valueForKey("channels") as? NSDictionary {
            let keys = channels.keyEnumerator()
            while let channelName = keys.nextObject() as? String {
                // Only grab channels that we care about
                if let index = Constants.channelNames.indexOf(channelName) {
                    // NOTICE: we must also make sure that this specific channel was updated
                    // in the past 24 hours ("maxTime").
                    let channel = channels.valueForKey(channelName) as! NSDictionary
                    let channelTime = channel.valueForKey("maxTimeSecs") as! Double
                    if channelTime >= maxTime {
                        feedChannels.append(parseChannelFromJson(channelName, feed: result, dataEntry: channel))
                        break
                    }
                }
            }
            result.channels = feedChannels
        }
        
        return result
    }
    
    
    static func parseChannelFromJson(channelName: String, feed: Feed, dataEntry: NSDictionary) -> Channel {
        let channel = Channel()
        
        let minTimeSecs = dataEntry.valueForKey("minTimeSecs") as! Double
        let maxTimeSecs = dataEntry.valueForKey("maxTimeSecs") as! Double
        let minValue = dataEntry.valueForKey("minValue") as! Double
        let maxValue = dataEntry.valueForKey("maxValue") as! Double
        
        channel.name = channelName
        channel.feed = feed
        channel.minTimeSecs = minTimeSecs
        channel.maxTimeSecs = maxTimeSecs
        channel.minValue = minValue
        channel.maxValue = maxValue
        
        return channel
    }
    
    
    static func parseTiles(dataEntry: NSDictionary, fromTime: Int, toTime: Int) -> [Int: [Double]] {
        var results: [Int: [Double]]
        results = [Int: [Double]]()
        
        // grab all tiles within timestamp range (fromTime..toTime)
        let data = dataEntry.valueForKey("data") as! NSDictionary
        let innerData = data.valueForKey("data") as! NSArray
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
    
    
    static func parseDailyFeedTracker(feed: Feed, dataEntry: NSDictionary) -> DailyFeedTracker {
        var result = DailyFeedTracker(feed: feed)
        
        // TODO parse
        
        return result
    }
    
}