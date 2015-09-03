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
            var resultAddress = SimpleAddress()
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
                var feed = JsonParser.parseFeedFromJson(row, maxTime: maxTime)
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
        var result = Feed()
        var feedChannels = Array<Channel>()
        
        let feed_id = dataEntry.valueForKey("id") as! String
        let name = dataEntry.valueForKey("name") as! String
        let exposure = dataEntry.valueForKey("exposure") as! String
        let isMobile = dataEntry.valueForKey("isMobile") as! String
        let latitude = dataEntry.valueForKey("latitude") as! String
        let longitude = dataEntry.valueForKey("longitude") as! String
        let productId = dataEntry.valueForKey("productId") as! String
        
        result.feed_id = NSString(string: feed_id).integerValue
        result.name = name
        result.exposure = exposure
        result.isMobile = isMobile == "1"
        result.location.latitude = NSString(string: latitude).doubleValue
        result.location.longitude = NSString(string: longitude).doubleValue
        result.productId = NSString(string: productId).integerValue
        
        let channels = dataEntry.valueForKey("channelBounds")?.valueForKey("channels") as! NSDictionary
        let keys = channels.keyEnumerator()
        while let channelName = keys.nextObject() as? String {
            // Only grab channels that we care about
            if let index = find(Constants.channelNames,channelName) {
                // NOTICE: we must also make sure that this specific channel was updated
                // in the past 24 hours ("maxTime").
                let channel = channels.valueForKey(channelName) as! NSDictionary
                let channelTime = channel.valueForKey("maxTimeSecs") as! String
                if (NSString(string: channelTime).doubleValue >= maxTime) {
                    feedChannels.append(JsonParser.parseChannelFromJson(channelName, feed: result, dataEntry: channel))
                    break
                }
            }
        }
        result.channels = feedChannels
        return result
    }
    
    
    static func parseChannelFromJson(channelName: String, feed: Feed, dataEntry: NSDictionary) -> Channel {
        var channel = Channel()
        
        let minTimeSecs = dataEntry.valueForKey("minTimeSecs") as! String
        let maxTimeSecs = dataEntry.valueForKey("maxTimeSecs") as! String
        let minValue = dataEntry.valueForKey("minValue") as! String
        let maxValue = dataEntry.valueForKey("maxValue") as! String
        
        channel.name = channelName
        channel.feed = feed
        channel.minTimeSecs = NSString(string: minTimeSecs).doubleValue
        channel.maxTimeSecs = NSString(string: maxTimeSecs).doubleValue
        channel.minValue = NSString(string: minValue).doubleValue
        channel.maxValue = NSString(string: maxValue).doubleValue
        
        return channel
    }
    
}