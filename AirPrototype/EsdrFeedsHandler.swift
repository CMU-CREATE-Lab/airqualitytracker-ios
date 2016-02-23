//
//  EsdrFeedsHandler.swift
//  AirPrototype
//
//  Created by mtasota on 8/26/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrFeedsHandler {
    
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    
    
    private func requestChannelReading(authToken: String?, feed: Feed, channel: Channel, maxTime: Double?) {
        let feedId = channel.feed.feed_id.description
        let channelName = channel.name
        let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        
        // handles http response
        func completionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                var temp:NSDictionary
                
                // NOTE (from Chris)
                // "don't expect mostRecentDataSample to always exist in the response for every channel,
                // and don't expect channelBounds.maxTimeSecs to always equal mostRecentDataSample.timeSecs"
                temp = data?.valueForKey("data") as! NSDictionary
                temp = temp.valueForKey("channels") as! NSDictionary
                temp = temp.valueForKey(channelName) as! NSDictionary
                temp = temp.valueForKey("mostRecentDataSample") as! NSDictionary
                
                let resultValue = temp.valueForKey("value") as? NSNumber
                let resultTime = temp.valueForKey("timeSecs") as? NSNumber
                if resultValue != nil && resultTime != nil {
                    if maxTime == nil {
                        feed.setReadableValueType(Feed.ReadableValueType.INSTANTCAST)
                        channel.instantcastValue = resultValue!.doubleValue
                        feed.lastTime = resultTime!.doubleValue
                    } else {
                        if maxTime <= resultTime!.doubleValue {
                            feed.setReadableValueType(Feed.ReadableValueType.INSTANTCAST)
                            channel.instantcastValue = resultValue!.doubleValue
                            feed.lastTime = resultTime!.doubleValue
                        } else {
                            feed.setReadableValueType(Feed.ReadableValueType.NONE)
                            channel.instantcastValue = 0
                            NSLog("found FEED VALUE out of bounds")
                            feed.lastTime = resultTime!.doubleValue
                        }
                    }
                    GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
                }
                
            }
        }
        
        // make & send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
        if authToken == nil {
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
        } else {
            GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken!, urlRequest: request, completionHandler: completionHandler)
        }
    }
    
    
    // TODO clean up/refactor duplicates
    func requestChannelReadingFromApiKey(feed: Speck, channel: Channel, maxTime: Double?) {
        let apiKeyReadOnly = feed.apiKeyReadOnly!
        let channelName = channel.name
        let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        
        // handles http response
        func completionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                var temp:NSDictionary
                
                // NOTE (from Chris)
                // "don't expect mostRecentDataSample to always exist in the response for every channel,
                // and don't expect channelBounds.maxTimeSecs to always equal mostRecentDataSample.timeSecs"
                temp = data?.valueForKey("data") as! NSDictionary
                temp = temp.valueForKey("channels") as! NSDictionary
                temp = temp.valueForKey(channelName) as! NSDictionary
                temp = temp.valueForKey("mostRecentDataSample") as! NSDictionary
                
                let resultValue = temp.valueForKey("value") as? NSNumber
                let resultTime = temp.valueForKey("timeSecs") as? NSNumber
                if resultValue != nil && resultTime != nil {
                    if maxTime == nil {
                        feed.setReadableValueType(Feed.ReadableValueType.INSTANTCAST)
                        channel.instantcastValue = resultValue!.doubleValue
                        feed.lastTime = resultTime!.doubleValue
                    } else {
                        if maxTime <= resultTime!.doubleValue {
                            channel.instantcastValue = resultValue!.doubleValue
                            feed.setReadableValueType(Feed.ReadableValueType.INSTANTCAST)
                            feed.lastTime = resultTime!.doubleValue
                        } else {
                            channel.instantcastValue = 0
                            feed.setReadableValueType(Feed.ReadableValueType.NONE)
                            NSLog("found FEED VALUE out of bounds")
                            feed.lastTime = resultTime!.doubleValue
                        }
                    }
                    GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
                }
                
            }
        }
        
        // make & send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + apiKeyReadOnly + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestFeeds(location: Location, withinSeconds: Double, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let bottomLeftPoint = Location(latitude: location.latitude - Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude - Constants.MapGeometry.BOUNDBOX_LONG)
        let topRightPoint = Location(latitude: location.latitude + Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude + Constants.MapGeometry.BOUNDBOX_LONG)
        
        // make & send request
        let request = HttpHelper.generateRequest(
            Constants.Esdr.API_URL +
                "/api/v1/feeds" +
                "?whereJoin=AND&whereOr=productId=11,productId=1" +
                "&whereAnd=latitude>=\(bottomLeftPoint.latitude),latitude<=\(topRightPoint.latitude),longitude>=\(bottomLeftPoint.longitude),longitude<=\(topRightPoint.longitude),maxTimeSecs>=\(withinSeconds),exposure=outdoor" +
                "&fields=id,name,exposure,isMobile,latitude,latitude,longitude,productId,channelBounds",
            httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestChannelReading(feed: Feed, channel: Channel) {
        if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Feed.ReadableValueType.INSTANTCAST {
            requestChannelReading(nil, feed: feed, channel: channel, maxTime: nil)
        } else if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Feed.ReadableValueType.NOWCAST {
            channel.requestNowCast()
        }
    }
    
    
    func requestAuthorizedChannelReading(authToken: String, feed: Feed, channel: Channel) {
        let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        requestChannelReading(authToken, feed: feed, channel: channel, maxTime: timeRange)
    }
    
    
    func requestUpdateFeeds(address: SimpleAddress) {
        address.feeds.removeAll(keepCapacity: false)
        address.closestFeed = nil
        // the past 24 hours
        let maxTime = NSDate().timeIntervalSince1970 - Constants.READINGS_MAX_TIME_RANGE
        
        func completionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                
                address.feeds.appendContentsOf(EsdrJsonParser.populateFeedsFromJson(data!, maxTime: maxTime))
                if address.feeds.count > 0 {
                    if let closestFeed = MapGeometry.getClosestFeedToAddress(address, feeds: address.feeds) {
                        address.closestFeed = closestFeed
                        
                        // Responsible for calculating the value to be displayed
                        if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Feed.ReadableValueType.NOWCAST {
                            closestFeed.channels[0].requestNowCast()
                        } else if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Feed.ReadableValueType.INSTANTCAST {
                            requestChannelReading(nil, feed: closestFeed, channel: closestFeed.channels[0], maxTime: maxTime)
                        }
                    } else {
                        NSLog("Found non-zero feeds but closestFeed DNE?")
                    }
                }
            }
        }
        requestFeeds(address.location, withinSeconds: maxTime, completionHandler: completionHandler)
    }
    
    
    func requestUpdate(speck: Speck) {
        if speck.channels.count > 0 {
            let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
            requestChannelReadingFromApiKey(speck, channel: speck.channels[0], maxTime: timeRange)
        } else {
            NSLog("No channels found from speck id=\(speck.feed_id)")
        }
    }
    
}