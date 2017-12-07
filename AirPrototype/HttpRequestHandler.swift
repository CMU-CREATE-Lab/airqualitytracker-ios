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
        appDelegate = (UIApplication.shared.delegate! as? AppDelegate)!
    }
    
    
    fileprivate func send(_ urlRequest: URLRequest, additionalHeaders: [AnyHashable: Any]?, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = additionalHeaders
        let session = URLSession(configuration: sessionConfiguration)
        let downloadTask = session.downloadTask(with: urlRequest, completionHandler: completionHandler)
        downloadTask.resume()
    }
    
    
    func sendRequest(_ urlRequest: URLRequest, completionHandler: (@escaping (URL?, URLResponse?, Error?) -> Void) ) {
        self.send(urlRequest, additionalHeaders: nil, completionHandler: completionHandler)
    }
    
    
    func sendJsonRequest(_ urlRequest: URLRequest, completionHandler: (@escaping (URL?, URLResponse?, Error?) -> Void) ) {
        let additionalHeaders = [
            "Content-Type" : "application/json"
        ]
        self.send(urlRequest, additionalHeaders: additionalHeaders, completionHandler: completionHandler)
    }


    func sendAuthorizedJsonRequest(_ authToken: String, urlRequest: URLRequest, completionHandler: (@escaping (URL?, URLResponse?, Error?) -> Void) ) {
        let additionalHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(authToken)"
        ]
        self.send(urlRequest, additionalHeaders: additionalHeaders, completionHandler: completionHandler)
    }
    
    
    func requestGeocodingFromApi(_ input: String, completionHandler: (@escaping (URL?, URLResponse?, Error?) -> Void)) {
        let request = HttpHelper.generateRequest("http://autocomplete.wunderground.com/aq?query=\(input)&c=US", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
    }
    
}
