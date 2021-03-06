//
//  EsdrTilesHandler.swift
//  AirPrototype
//
//  Created by mtasota on 1/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrTilesHandler {
    
    
    // ASSERT: a and b will never share keys (timestamps)
    fileprivate func union(_ a: [Int: [Double]], and b: [Int: [Double]]) -> [Int: [Double]] {
        var results = [Int: [Double]]()
        
        // Checking assertion for sanity
        if Set(a.keys).intersection(Set(b.keys)).count > 0 {
            NSLog("WARNING: non-empty intersection of keys in union (this shouldn't be happening); information will be lost")
        }
        
        // lazily set results (overwrites in the case of intersection, which shouldn't happen)
        for key in a.keys {
            results[key] = a[key]
        }
        for key in b.keys {
            results[key] = b[key]
        }
        
        return results
    }
    
    
    func requestTilesFromChannel(_ channel: Channel, timestamp: Int, completionHandler: @escaping (([Int: [Double]]) -> Void) ) {
        var firstResponse: [Int: [Double]]?
        var secondResponse: [Int: [Double]]?
        
        let maxTime = timestamp
        // TODO we use 13 hours since ESDR won't always report the previous hour to us
        //let minTime = timestamp - 3600*12
        let minTime = timestamp - 3600*13
        
        // Level is 2**11 => 2048 seconds
        let level = 11
        // our tile offset (calculates most recent tile at the current level)
        let offset = Int( Double(maxTime) / (512.0*pow(2.0,Double(level))) )
        
        // 1st handler, which then makes 2nd request; performs sequentially
        func firstHandler(_ url: URL?, response: URLResponse?, error: Error?) -> Void {
            // handles if an invalid response
            if !(HttpHelper.successfulResponse(response, error: error)) {
                return
            }
            
            // response handling
            let jsonString = try! NSString.init(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
            let formattedString = EsdrJsonParser.formatSafeJson(jsonString)
            let tempData = formattedString.data(using: String.Encoding.utf8.rawValue)
            let data = (try! JSONSerialization.jsonObject(with: tempData!, options: [])) as? NSDictionary
            firstResponse = EsdrJsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // send 2nd request
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed!.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset-1)", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: secondHandler)
        }
        
        // 2nd handler
        func secondHandler(_ url: URL?, response: URLResponse?, error: Error?) -> Void {
            // handles if an invalid response
            if !(HttpHelper.successfulResponse(response, error: error)) {
                return
            }
            
            // response handling
            let jsonString = try! NSString.init(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
            let formattedString = EsdrJsonParser.formatSafeJson(jsonString)
            let tempData = formattedString.data(using: String.Encoding.utf8.rawValue)
            let data = (try! JSONSerialization.jsonObject(with: tempData!, options: [])) as? NSDictionary
            secondResponse = EsdrJsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // union both responses then call completion handler
            let result = union(firstResponse!, and: secondResponse!)
            completionHandler(result)
        }
        
        // send 1st request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed!.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: firstHandler)
    }
    
    
    func requestFeedAverages(_ feed: Pm25Feed, from: Int, to: Int, response: @escaping (_ url: URL?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let channelName = feed.getPm25Channels().first!.name
        let requestUrl = Constants.Esdr.API_URL + "/api/v1/feeds/\(feed.feed_id)/channels/\(channelName)_daily_mean,\(channelName)_daily_median,\(channelName)_daily_max/export"
        let urlParams = "?format=json" + "&from=\(from)&to=\(to)"
        
        let request = HttpHelper.generateRequest(requestUrl+urlParams, httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: response)
    }
    
}
