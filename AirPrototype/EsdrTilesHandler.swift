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
    
    
    private func union(a: [Int: [Double]], and b: [Int: [Double]]) -> [Int: [Double]] {
        var results: [Int: [Double]]
        results = [Int: [Double]]()
        
        // TODO union two hashmaps a,b together
        
        return results
    }
    
    
    func requestTilesFromChannel(channel: Channel, completionHandler: (([Int: [Double]]) -> Void) ) {
        let timestamp = NSDate().timeIntervalSince1970
        let maxTime = Int(timestamp)
        let minTime = Int(timestamp - 3600*12)
        
        // Level is 2**11 => 2048 seconds
        let level = 11
        // our tile offset
        let offset = Int( Double(maxTime) / (512.0*pow(2.0,Double(level))) )
        
        var firstResponse: [Int: [Double]]?
        var secondResponse: [Int: [Double]]?
        
        // 1st handler, which then makes 2nd request; performs sequentially
        func firstHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
                return
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
                return
            }
            
            // response handling
            let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
            firstResponse = JsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // generate 2nd URL
            let address = Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset-1)"
            let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            
            // create 2nd request
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "GET"
            
            // send 2nd request
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: secondHandler)
        }
        
        // 2nd handler
        func secondHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
                return
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
                return
            }
            
            // response handling
            let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
            secondResponse = JsonParser.parseTiles(data!, fromTime: minTime, toTime: maxTime)
            
            // completion handler
            let result = union(firstResponse!, and: secondResponse!)
            completionHandler(result)
        }
        
        // generate 1st URL
        let address = Constants.Esdr.API_URL + "/api/v1/feeds/\(channel.feed.feed_id)/channels/\(channel.name)/tiles/\(level).\(offset)"
        let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create 1st request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send 1st request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: firstHandler)
    }
    
}