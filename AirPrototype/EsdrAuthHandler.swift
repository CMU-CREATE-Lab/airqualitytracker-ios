//
//  EsdrAuthHandler.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrAuthHandler {
    
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    
    
    func requestEsdrToken(username: String, password: String, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/oauth/token"
        let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let params:[String: String] = [
            "grant_type": Constants.Esdr.GRANT_TYPE_TOKEN,
            "client_id": Constants.AppSecrets.ESDR_CLIENT_ID,
            "client_secret": Constants.AppSecrets.ESDR_CLIENT_SECRET,
            "username": username,
            "password": password
        ]
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestEsdrRefresh(refreshToken: String, responseHandler: (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void ) {
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/oauth/token"
        var url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let params:[String: String] = [
            "grant_type": Constants.Esdr.GRANT_TYPE_REFRESH,
            "client_id": Constants.AppSecrets.ESDR_CLIENT_ID,
            "client_secret": Constants.AppSecrets.ESDR_CLIENT_SECRET,
            "refresh_token": refreshToken
        ]
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: responseHandler)
    }
    
}
