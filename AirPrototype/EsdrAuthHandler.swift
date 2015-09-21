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
    
    // singleton pattern; this is the only time the class should be initialized
    
    class var sharedInstance: EsdrAuthHandler {
        struct Singleton {
            static let instance = EsdrAuthHandler()
        }
        return Singleton.instance
    }
    
    // class variables/constructor

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
            "client_id": Constants.Esdr.CLIENT_ID,
            "client_secret": Constants.Esdr.CLIENT_SECRET,
            "username": username,
            "password": password
        ]
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        
        // send request
        HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
    
    func requestEsdrRefresh(refreshToken: String) {
        // generate safe URL
        let address = Constants.Esdr.API_URL + "/oauth/token"
        var url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let params:[String: String] = [
            "grant_type": Constants.Esdr.GRANT_TYPE_REFRESH,
            "client_id": Constants.Esdr.CLIENT_ID,
            "client_secret": Constants.Esdr.CLIENT_SECRET,
            "refresh_token": refreshToken
        ]
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        
        // response handler
        func responseHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
            if error != nil {
                NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
            } else {
                NSLog("Responded with \(response!.description)")
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                let access_token = data!.valueForKey("access_token") as? String
                let refresh_token = data!.valueForKey("refresh_token") as? String
                if access_token != nil && refresh_token != nil {
                    NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                    SettingsHandler.sharedInstance.updateEsdrTokens(access_token!, refreshToken: refresh_token!)
                } else {
                    NSLog("Failed to grab access/refresh token(s)")
                }
            }
        }
        
        // send request
        HttpRequestHandler.sharedInstance.sendJsonRequest(request, completionHandler: responseHandler)
    }
    
}
