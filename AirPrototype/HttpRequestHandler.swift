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
    
    
    private func send(urlRequest: NSMutableURLRequest, additionalHeaders: [NSObject:AnyObject]?, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = additionalHeaders
        let session = NSURLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTaskWithRequest(urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }
    
    
    func sendRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        self.send(urlRequest, additionalHeaders: nil, completionHandler: completionHandler)
    }
    
    
    func sendJsonRequest(urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let additionalHeaders = [
            "Content-Type" : "application/json"
        ]
        self.send(urlRequest, additionalHeaders: additionalHeaders, completionHandler: completionHandler)
    }


    func sendAuthorizedJsonRequest(authToken: String, urlRequest: NSMutableURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        let additionalHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(authToken)"
        ]
        self.send(urlRequest, additionalHeaders: additionalHeaders, completionHandler: completionHandler)
    }
    
    
    func requestGeocodingFromApi(input: String, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void)) {
        let request = HttpHelper.generateRequest("http://autocomplete.wunderground.com/aq?query=\(input)&c=US", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
}
