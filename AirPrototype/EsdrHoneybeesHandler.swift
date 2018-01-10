//
//  EsdrHoneybeesHandler.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 12/14/17.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

import Foundation

class EsdrHoneybeesHandler {
    
    let HONEYBEE_PRODUCT_ID = 67
    
    
    func requestHoneybeeFeeds(_ authToken: String, userId: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",deviceId<>\(id)"
            }
        }
        
        // send request
        // NOTE: we order by "modified" date so most recently active speck feeds (with device) are added first (thanks, chris!)
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds?whereAnd=userId=\(userId),productId=\(HONEYBEE_PRODUCT_ID)\(listDevices)&orderBy=-modified", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request as URLRequest, completionHandler: completionHandler)
    }
    
    
    func requestHoneybeeDevices(_ authToken: String, userId: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        var listDevices = ""
        if let blacklistedDevices = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            for id in blacklistedDevices {
                listDevices += ",id<>\(id)"
            }
        }
        
        // send request
        NSLog(Constants.Esdr.API_URL + "/api/v1/devices?whereAnd=userId=\(userId),productId=\(HONEYBEE_PRODUCT_ID)\(listDevices)")
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/devices?whereAnd=userId=\(userId),productId=\(HONEYBEE_PRODUCT_ID)\(listDevices)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(authToken, urlRequest: request as URLRequest, completionHandler: completionHandler)
    }
    
    
    func requestChannelsForHoneybee(_ honeybee: Honeybee) {
        // completion handler
        func completionHandler(_ url: URL?, reponse: URLResponse?, error: Error?) -> Void {
            let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as! NSDictionary
            let dataEntry = data.value(forKey: "data") as! NSDictionary
            if let channels = (dataEntry.value(forKey: "channelBounds") as AnyObject).value(forKey: "channels") as? NSDictionary {
                // TODO enumerate through channels and add for Honeybee
                
//                let keys = channels.keyEnumerator()
//                while let channelName = keys.nextObject() as? String {
//                    // NOTICE: we must also make sure that this specific channel was updated
//                    // in the past 24 hours ("maxTime").
//                    let channel = channels.value(forKey: channelName) as! NSDictionary
//                    let channelTime = channel.value(forKey: "maxTimeSecs") as! Double
//                    honeybee.addChannel(EsdrJsonParser.parseChannelFromJson(channelName, feed: honeybee, dataEntry: channel))
//                }
//                GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(honeybee)
            }
        }
        
        // send request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(honeybee.apiKeyReadOnly!)?fields=channelBounds", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
    }
    
}
