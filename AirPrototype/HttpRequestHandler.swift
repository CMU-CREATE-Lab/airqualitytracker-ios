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
    
    
    // TODO http stuff
    func sendJsonRequest(url: NSURL, completionHandler: ((NSURL!, NSURLResponse!, NSError!) -> Void)? ) {
        let sharedSessionNSURL = NSURLSession.sharedSession()
        sharedSessionNSURL.downloadTaskWithURL(url, completionHandler: completionHandler).resume()
    }
}
