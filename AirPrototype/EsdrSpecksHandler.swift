//
//  EsdrSpecksHandler.swift
//  AirPrototype
//
//  Created by mtasota on 12/17/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrSpecksHandler {
    
    
    func requestSpeckFeeds(authToken: String, userId: Int, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        // generate safe URL
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",deviceId<>\(id)"
            }
        }
        let address = Constants.Esdr.API_URL + "/api/v1/feeds"
        let params = "?whereAnd=userId=\(userId),productId=9\(listDevices)"
        let url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request, completionHandler: completionHandler)
    }
    
    
    func requestSpeckDevices(authToken: String, userId: Int, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        // generate safe URL
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",id<>\(id)"
            }
        }
        let address = Constants.Esdr.API_URL + "/api/v1/devices"
        let params = "?whereAnd=userId=\(userId),productId=9\(listDevices)"
        let url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request, completionHandler: completionHandler)
    }
    
    
    // ASSERT: speck.apiKeyReadOnly not blank
    func requestChannelsForSpeck(speck: Speck) {
        // completion handler
        func completionHandler(url: NSURL?, reponse: NSURLResponse?, error: NSError?) -> Void {
            var feedChannels = Array<Channel>()
            let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as! NSDictionary
            let dataEntry = data.valueForKey("data") as! NSDictionary
            if let channels = dataEntry.valueForKey("channelBounds")?.valueForKey("channels") as? NSDictionary {
                let keys = channels.keyEnumerator()
                while let channelName = keys.nextObject() as? String {
                    // Only grab channels that we care about
                    if let index = Constants.channelNames.indexOf(channelName) {
                        // NOTICE: we must also make sure that this specific channel was updated
                        // in the past 24 hours ("maxTime").
                        let channel = channels.valueForKey(channelName) as! NSDictionary
                        let channelTime = channel.valueForKey("maxTimeSecs") as! Double
                        feedChannels.append(JsonParser.parseChannelFromJson(channelName, feed: speck, dataEntry: channel))
                        break
                    }
                }
                speck.channels = feedChannels
                speck.requestUpdate()
            }
        }
        
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/api/v1/feeds/\(speck.apiKeyReadOnly!)"
        let params = "?fields=channelBounds"
        let url = NSURL(string: (address+params).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }

}