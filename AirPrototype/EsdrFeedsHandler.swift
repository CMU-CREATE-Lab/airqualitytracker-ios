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
    // singleton pattern; this is the only time the class should be initialized
    class var sharedInstance: EsdrFeedsHandler {
        struct Singleton {
            static let instance = EsdrFeedsHandler()
        }
        return Singleton.instance
    }
    
    
    func requestFeeds(location: Location, withinSeconds: Double, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        let bottomLeftPoint = Location(latitude: location.latitude - Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude - Constants.MapGeometry.BOUNDBOX_LONG)
        let topRightPoint = Location(latitude: location.latitude + Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude + Constants.MapGeometry.BOUNDBOX_LONG)
        
        let address = Constants.Esdr.API_URL + "/api/v1/feeds"
        let params = "?whereOr=ProductId=11,ProductId=1" +
            "&whereAnd=latitude>=\(bottomLeftPoint.latitude),latitude<=\(topRightPoint.latitude),longitude>=\(bottomLeftPoint.longitude),longitude<=\(topRightPoint.longitude),maxTimeSecs>=\(withinSeconds),exposure=outdoor" +
            "&fields=id,name,exposure,isMobile,latitude,latitude,longitude,productId,channelBounds"
        var url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestPrivateFeeds(authToken: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        let address = Constants.Esdr.API_URL + "/api/v1/feeds"
        let params = "?whereAnd=isPublic=0,productId=9"
        var url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        HttpRequestHandler.sharedInstance.sendAuthorizedJsonRequest(authToken, urlRequest: request, completionHandler: completionHandler)
    }
    
    
    func requestChannelReading(authToken: String?, feed: Feed, channel: Channel, maxTime: Double?) {
        let feedId = channel.feed.feed_id.description
        let channelName = channel.name
        
        func completionHandler(url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void {
            let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as? NSDictionary
            var temp:NSDictionary
            
            // NOTE (from Chris)
            // "don't expect mostRecentDataSample to always exist in the response for every channel,
            // and don't expect channelBounds.maxTimeSecs to always equal mostRecentDataSample.timeSecs"
            temp = data?.valueForKey("data") as! NSDictionary
            temp = temp.valueForKey("channels") as! NSDictionary
            temp = temp.valueForKey(channelName) as! NSDictionary
            temp = temp.valueForKey("mostRecentDataSample") as! NSDictionary
            
            let resultValue = temp.valueForKey("value") as? String
            let resultTime = temp.valueForKey("timeSecs") as? String
            if resultValue != nil && resultTime != nil {
                if maxTime == nil {
                    feed.feedValue = NSString(string: resultValue!).doubleValue
                    feed.lastTime = NSString(string: resultTime!).doubleValue
                } else {
                    if maxTime <= NSString(string: resultTime!).doubleValue {
                        feed.setHasReadableValue(true)
                        feed.feedValue = NSString(string: resultValue!).doubleValue
                        feed.lastTime = NSString(string: resultTime!).doubleValue
                    } else {
                        feed.setHasReadableValue(false)
                        feed.feedValue = 0
                        feed.lastTime = NSString(string: resultTime!).doubleValue
                    }
                }
                // TODO GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
            }
        }
        
        let address = Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent"
        var url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        if (authToken == nil) {
            HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: completionHandler)
        } else {
            HttpRequestHandler.sharedInstance.sendAuthorizedJsonRequest(authToken!, urlRequest: request, completionHandler: completionHandler)
        }
    }
    
}