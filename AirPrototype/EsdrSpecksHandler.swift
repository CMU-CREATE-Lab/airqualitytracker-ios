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
    
    
    func requestSpeckFeeds(_ authToken: String, userId: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",deviceId<>\(id)"
            }
        }
        
        // send request
        // NOTE: we order by "modified" date so most recently active speck feeds (with device) are added first (thanks, chris!)
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds?whereAnd=userId=\(userId),productId=9\(listDevices)&orderBy=-modified", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request as URLRequest, completionHandler: completionHandler)
    }
    
    
    func requestSpeckDevices(_ authToken: String, userId: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",id<>\(id)"
            }
        }
        
        // send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/devices?whereAnd=userId=\(userId),productId=9\(listDevices)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request as URLRequest, completionHandler: completionHandler)
    }
    
    
    // ASSERT: speck.apiKeyReadOnly not blank
    func requestChannelsForSpeck(_ speck: Speck) {
        // completion handler
        func completionHandler(_ url: URL?, reponse: URLResponse?, error: Error?) -> Void {
            let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as! NSDictionary
            let dataEntry = data.value(forKey: "data") as! NSDictionary
            if let channels = (dataEntry.value(forKey: "channelBounds") as AnyObject).value(forKey: "channels") as? NSDictionary {
                let keys = channels.keyEnumerator()
                while let channelName = keys.nextObject() as? String {
                    // NOTICE: we must also make sure that this specific channel was updated
                    // in the past 24 hours ("maxTime").
                    let channel = channels.value(forKey: channelName) as! NSDictionary
                    let channelTime = channel.value(forKey: "maxTimeSecs") as! Double
                    speck.addChannel(EsdrJsonParser.parseChannelFromJson(channelName, feed: speck, dataEntry: channel))
                }
                GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(speck)
            }
        }
        
        // send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(speck.apiKeyReadOnly!)?fields=channelBounds", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
    }

}
