//
//  JsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 7/22/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class JsonParser {
    
    
    static func parseAddressesFromJson(data: NSDictionary) -> Array<SimpleAddress> {
        var result = Array<SimpleAddress>()
        let addresses = data.valueForKey("RESULTS") as! Array<NSDictionary>
        for address in addresses {
            let resultAddress = SimpleAddress()
            if let latitude = address.valueForKey("lat") as? String {
                resultAddress.location.latitude = NSString(string: latitude).doubleValue
            }
            if let longitude = address.valueForKey("lon") as? String {
                resultAddress.location.longitude = NSString(string: longitude).doubleValue
            }
            if let name = address.valueForKey("name") as? String {
                resultAddress.name = name
            }
            // TODO string needs formatted
            if let zip = address.valueForKey("zmw") as? String {
                resultAddress.zipcode = zip
            }
            result.append(resultAddress)
        }
        return result
    }
    
    
    static func populateFeedsFromJson(data: NSDictionary, maxTime: Double) -> [Feed] {
        var feeds = Array<Feed>()
        if let rows = (data.valueForKey("data") as! NSDictionary).valueForKey("rows") as? Array<NSDictionary> {
            for row in rows {
                let feed = JsonParser.parseFeedFromJson(row, maxTime: maxTime)
                // only consider non-null feeds with at least 1 channel
                if feed.channels.count > 0 {
                    feeds.append(feed)
                }
            }
        }
        return feeds
    }
    
    
    static func populateAllFeedsFromJson(data: NSDictionary) -> [Feed] {
        return populateFeedsFromJson(data, maxTime: 0)
    }
    
    
    static func parseFeedFromJson(dataEntry: NSDictionary, maxTime: Double) -> Feed {
        let result = Feed()
        var feedChannels = Array<Channel>()
        
        let feed_id = dataEntry.valueForKey("id") as! Int
        let name = dataEntry.valueForKey("name") as! String
        let exposure = dataEntry.valueForKey("exposure") as! String
        let isMobile = dataEntry.valueForKey("isMobile") as! Int
        let latitude = dataEntry.valueForKey("latitude") as! Double
        let longitude = dataEntry.valueForKey("longitude") as! Double
        let productId = dataEntry.valueForKey("productId") as! Int
        
        result.feed_id = feed_id
        result.name = name
        result.exposure = exposure
        result.isMobile = isMobile == 1
        result.location.latitude = latitude
        result.location.longitude = longitude
        result.productId = productId
        
        let channels = dataEntry.valueForKey("channelBounds")?.valueForKey("channels") as! NSDictionary
        let keys = channels.keyEnumerator()
        while let channelName = keys.nextObject() as? String {
            // Only grab channels that we care about
            if let index = Constants.channelNames.indexOf(channelName) {
                // NOTICE: we must also make sure that this specific channel was updated
                // in the past 24 hours ("maxTime").
                let channel = channels.valueForKey(channelName) as! NSDictionary
                let channelTime = channel.valueForKey("maxTimeSecs") as! Double
                if channelTime >= maxTime {
                    feedChannels.append(JsonParser.parseChannelFromJson(channelName, feed: result, dataEntry: channel))
                    break
                }
            }
        }
        result.channels = feedChannels
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
    
}