//
//  HttpRequestHandler.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class HttpRequestHandler {
    
    // singleton pattern; this is the only time the class should be initialized
    
    class var sharedInstance: HttpRequestHandler {
        struct Singleton {
            static let instance = HttpRequestHandler()
        }
        return Singleton.instance
    }
    
    // class variables/constructor
    
    var appDelegate: AppDelegate
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    
    
    func sendJsonRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = [
            "Content-Type" : "application/json"
        ]
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }


    func sendAuthorizedJsonRequest(authToken: String, urlRequest: NSMutableURLRequest, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(authToken)"
        ]
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }


    func requestFeeds(location: Location, withinSeconds: Double, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)?) {
        EsdrFeedsHandler.sharedInstance.requestFeeds(location, withinSeconds: withinSeconds, completionHandler: completionHandler)
    }

    func requestSpecks(authToken: String, userId: Int, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        EsdrFeedsHandler.sharedInstance.requestSpecks(authToken, userId: userId, completionHandler: completionHandler)
    }


    func requestChannelReading(feed: Feed, channel: Channel) {
        EsdrFeedsHandler.sharedInstance.requestChannelReading(nil, feed: feed, channel: channel, maxTime: nil)
    }


    func requestAuthorizedChannelReading(authToken: String, feed: Feed, channel: Channel) {
        let timeRange = NSDate().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        EsdrFeedsHandler.sharedInstance.requestChannelReading(authToken, feed: feed, channel: channel, maxTime: timeRange)
    }


    func requestEsdrToken(username: String, password: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        EsdrAuthHandler.sharedInstance.requestEsdrToken(username, password: password, completionHandler: completionHandler)
    }


    func requestEsdrRefresh(refreshToken: String) {
        EsdrAuthHandler.sharedInstance.requestEsdrRefresh(refreshToken)
    }
    
    
    // TODO consider CLGeocoder: func geocodeAddressString(String, CLGeocodeCompletionHandler)
    func requestGeocodingFromApi(input: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)?) {
        let url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
}
