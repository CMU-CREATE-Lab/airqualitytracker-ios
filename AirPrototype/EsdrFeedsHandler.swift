//
//  EsdrFeedsHandler.swift
//  AirPrototype
//
//  Created by mtasota on 8/26/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrFeedsHandler {
    var appDelegate: AppDelegate
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    // singleton pattern; this is the only time the class should be initialized
    class var sharedInstance: EsdrFeedsHandler {
        struct Singleton {
            static let instance = EsdrFeedsHandler()
        }
        return Singleton.instance
    }
    
    
    //    // TODO http stuff
    //    func sendJsonRequest(url: NSURL, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
    //        let sharedSessionNSURL = NSURLSession.sharedSession()
    //        sharedSessionNSURL.downloadTaskWithURL(url, completionHandler: completionHandler).resume()
    //
    //        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    //        let token = "token_value"
    //        sessionConfiguration.HTTPAdditionalHeaders = [
    //            "Content-Type" : "application/json"
    //            ,
    //            "Authorization" : "Bearer \(token)"
    //        ]
    //        let session = NSURLSession(configuration: sessionConfiguration)
    //
    //        let params = "value=1&something=else"
    //        let request = NSMutableURLRequest(URL: url)
    //        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    //        request.HTTPMethod = "GET"
    //
    ////        session.downloadTaskWithRequest(<#request: NSURLRequest#>)
    //    }
    
    
    
}