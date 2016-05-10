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
    private func union(a: [Int: [Double]], and b: [Int: [Double]]) -> [Int: [Double]] {
        var results = [Int: [Double]]()
        
        // Checking assertion for sanity
        if Set(a.keys).intersect(Set(b.keys)).count > 0 {
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
    
    
    private func formatSafeJson(json: NSString) -> NSString {
        var result = json
        
        // remove occurences of strings that break json parser (ex: -1e+308=>0)
        result = result.stringByReplacingOccurrencesOfString("-1e+308", withString: "0")
        
        return result
    }
    
    
    func requestTilesFromChannel(channel: Channel, timestamp: Int, completionHandler: (([Int: [Double]]) -> Void) ) {
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
        func firstHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            // handles if an invalid response
            if !(HttpHelper.successfulResponse(response, error: error)) {
                return
            }
            
            // response handling
            let jsonString = try! NSString.init(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
            let formattedString = formatSafeJson(jsonString)
            let tempData = formattedString.dataUsingEncoding(NSUTF8StringEncoding)
            let data = (try! NSJSONSerialization.JSONObjectWithData(tempData!, options: [])) as? NSDictionary
            firstResponse = EsdrJsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // send 2nd request
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset-1)", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: secondHandler)
        }
        
        // 2nd handler
        func secondHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            // handles if an invalid response
            if !(HttpHelper.successfulResponse(response, error: error)) {
                return
            }
            
            // response handling
            let jsonString = try! NSString.init(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
            let formattedString = formatSafeJson(jsonString)
            let tempData = formattedString.dataUsingEncoding(NSUTF8StringEncoding)
            let data = (try! NSJSONSerialization.JSONObjectWithData(tempData!, options: [])) as? NSDictionary
            secondResponse = EsdrJsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // union both responses then call completion handler
            let result = union(firstResponse!, and: secondResponse!)
            completionHandler(result)
        }
        
        // send 1st request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: firstHandler)
    }
    
    
    func requestFeedAverages(feed: Feed, response: (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void) {
        // TODO given a Feed, construct the ESDR request to grab average values over a channel
        // TODO time range (1 year up till now)
        
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/TODO_URL", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: response)
    }
    
}