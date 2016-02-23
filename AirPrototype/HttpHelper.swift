//
//  RequestConstructor.swift
//  AirPrototype
//
//  Created by mtasota on 2/23/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class HttpHelper {
    
    
    static func generateRequest(url: String, httpMethod: String?) -> NSMutableURLRequest {
        let string = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: string!)
        if let method = httpMethod {
            request.HTTPMethod = method
        }
        return request
    }
    
    
    static func successfulResponse(response: NSURLResponse?, error: NSError?) -> Bool {
        let httpResponse = response as! NSHTTPURLResponse
        if error != nil {
            NSLog("successfulResponse: error is not nil")
        } else if httpResponse.statusCode != 200 {
            // not sure if necessary... error usually is not nil but crashed
            // on me one time when starting up simulator & running
            NSLog("successfulResponse: Got status code \(httpResponse.statusCode) != 200")
        } else {
            return true
        }
        return false
    }
    
}