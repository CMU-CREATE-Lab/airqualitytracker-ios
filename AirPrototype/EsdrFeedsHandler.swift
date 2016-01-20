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
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("requestChannelReading: error is not nil")
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("requestChannelReading: Got status code \(httpResponse.statusCode) != 200")
            } else {
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
                        feed.feedValue = resultValue!.doubleValue
                        NSLog("forced FEED VALUE of \(feed.feedValue)")
                        feed.lastTime = resultTime!.doubleValue
                    } else {
                        if maxTime <= resultTime!.doubleValue {
                            feed.setHasReadableValue(true)
                            feed.feedValue = resultValue!.doubleValue
                            NSLog("found FEED VALUE of \(feed.feedValue)")
                            feed.lastTime = resultTime!.doubleValue
                        } else {
                            feed.setHasReadableValue(false)
                            feed.feedValue = 0
                            NSLog("found FEED VALUE out of bounds")
                            feed.lastTime = resultTime!.doubleValue
                        }
                    }
                    GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
                }
                
            }
        }
        
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent"
        let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        if authToken == nil {
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
        } else {
            GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken!, urlRequest: request, completionHandler: completionHandler)
        }
    }
    
    
    func requestFeeds(location: Location, withinSeconds: Double, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let bottomLeftPoint = Location(latitude: location.latitude - Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude - Constants.MapGeometry.BOUNDBOX_LONG)
        let topRightPoint = Location(latitude: location.latitude + Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude + Constants.MapGeometry.BOUNDBOX_LONG)
        
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/api/v1/feeds"
        let params = "?whereJoin=AND&whereOr=productId=11,productId=1" +
            "&whereAnd=latitude>=\(bottomLeftPoint.latitude),latitude<=\(topRightPoint.latitude),longitude>=\(bottomLeftPoint.longitude),longitude<=\(topRightPoint.longitude),maxTimeSecs>=\(withinSeconds),exposure=outdoor" +
            "&fields=id,name,exposure,isMobile,latitude,latitude,longitude,productId,channelBounds"
        let url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestChannelReading(feed: Feed, channel: Channel) {
        requestChannelReading(nil, feed: feed, channel: channel, maxTime: nil)
    }
    
    
    func requestAuthorizedChannelReading(authToken: String, feed: Feed, channel: Channel) {
        let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        requestChannelReading(authToken, feed: feed, channel: channel, maxTime: timeRange)
    }
    
    
    func requestUpdateFeeds(address: SimpleAddress) {
        NSLog("Called requestUpdateFeeds() on Address=\(address.name)")
        address.feeds.removeAll(keepCapacity: false)
        address.closestFeed = nil
        // the past 24 hours
        let maxTime = NSDate().timeIntervalSince1970 - Constants.READINGS_MAX_TIME_RANGE
        
        func completionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
            // TODO got an error here (forced type? Should handle if nil)
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
            } else {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                
                address.feeds.appendContentsOf(JsonParser.populateFeedsFromJson(data!, maxTime: maxTime))
                NSLog("populated \(address.feeds.count) feeds")
                if address.feeds.count > 0 {
                    NSLog("Found non-zero feeds")
                    if let closestFeed = MapGeometry.getClosestFeedToAddress(address, feeds: address.feeds) {
                        NSLog("closestFeed EXISTS!")
                        address.closestFeed = closestFeed
                        requestChannelReading(closestFeed, channel: closestFeed.channels[0])
                    } else {
                        NSLog("But... closestFeed DNE?")
                    }
                }
            }
            NSLog("Finished completionHandler in requestUpdateFeeds()")
        }
        requestFeeds(address.location, withinSeconds: maxTime, completionHandler: completionHandler)
    }
    
    
    func requestUpdate(speck: Speck) {
        if speck.channels.count > 0 {
            if let accessToken = GlobalHandler.sharedInstance.settingsHandler.accessToken {
                requestAuthorizedChannelReading(accessToken, feed: speck, channel: speck.channels[0])
            } else {
                NSLog("WARNING - could not request channel reading for Speck=\(speck.name); accessToken is nil.")
            }
        } else {
            NSLog("No channels found from speck id=\(speck.feed_id)")
        }
    }
    
}