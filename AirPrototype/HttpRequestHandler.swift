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
    var appDelegate: AppDelegate
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    // singleton pattern; this is the only time the class should be initialized
    class var sharedInstance: HttpRequestHandler {
        struct Singleton {
            static let instance = HttpRequestHandler()
        }
        return Singleton.instance
    }
    
    
    func sendJsonRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
//        let sharedSessionNSURL = NSURLSession.sharedSession()
//        sharedSessionNSURL.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler).resume()
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


    func requestFeeds(latitude: Double, longitude: Double, maxTime: Double, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)?) {
        // esdrFeedsHandler.requestFeeds(latd, longd, maxTime, response);
    }

    func requestPrivateFeeds(authToken: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        // esdrFeedsHandler.requestPrivateFeeds(authToken, response);
    }


    func requestChannelReading(feed: Feed, channel: Channel) {
        // esdrFeedsHandler.requestChannelReading("",feed, channel, 0);
    }


    func requestAuthorizedChannelReading(authToken: String, feed: Feed, channel: Channel) {
        // esdrFeedsHandler.requestChannelReading(authToken, feed, channel,
        //         (long)(new Date().getTime() / 1000.0) - Constants.SPECKS_MAX_TIME_RANGE);
    }


    func requestEsdrToken(username: String, password: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        // esdrAuthHandler.requestEsdrToken(username,password,response,error);
    }


    func requestEsdrRefresh(refreshToken: String) {
        // esdrAuthHandler.requestEsdrRefresh(refreshToken);
    }
    
    
    func requestGeocodingFromApi(input: String, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)?) {
        var url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
}
