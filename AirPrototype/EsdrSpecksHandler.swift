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
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",deviceId<>\(id)"
            }
        }
        
        // send request
        // NOTE: we order by "modified" date so most recently active speck feeds (with device) are added first (thanks, chris!)
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds?whereAnd=userId=\(userId),productId=9\(listDevices)&orderBy=-modified", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request, completionHandler: completionHandler)
    }
    
    
    func requestSpeckDevices(authToken: String, userId: Int, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",id<>\(id)"
            }
        }
        
        // send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/devices?whereAnd=userId=\(userId),productId=9\(listDevices)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request, completionHandler: completionHandler)
    }
    
    
    // ASSERT: speck.apiKeyReadOnly not blank
    func requestChannelsForSpeck(speck: Speck) {
        // completion handler
        func completionHandler(url: NSURL?, reponse: NSURLResponse?, error: NSError?) -> Void {
            let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as! NSDictionary
            let dataEntry = data.valueForKey("data") as! NSDictionary
            if let channels = dataEntry.valueForKey("channelBounds")?.valueForKey("channels") as? NSDictionary {
                let keys = channels.keyEnumerator()
                while let channelName = keys.nextObject() as? String {
                    // NOTICE: we must also make sure that this specific channel was updated
                    // in the past 24 hours ("maxTime").
                    let channel = channels.valueForKey(channelName) as! NSDictionary
                    let channelTime = channel.valueForKey("maxTimeSecs") as! Double
                    speck.addChannel(EsdrJsonParser.parseChannelFromJson(channelName, feed: speck, dataEntry: channel))
                }
                GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(speck)
            }
        }
        
        // send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(speck.apiKeyReadOnly!)?fields=channelBounds", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }

}
