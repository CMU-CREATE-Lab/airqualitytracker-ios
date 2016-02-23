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
    
    
    func sendRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }
    
    
    func sendJsonRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = [
            "Content-Type" : "application/json"
        ]
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }


    func sendAuthorizedJsonRequest(authToken: String, urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(authToken)"
        ]
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }
    
    
    // TODO consider CLGeocoder: func geocodeAddressString(String, CLGeocodeCompletionHandler)
    func requestGeocodingFromApi(input: String, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void)) {
        let url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
}
