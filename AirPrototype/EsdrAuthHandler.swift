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
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/oauth/token", httpMethod: "POST")
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
    
    
    // returns true when request is sent to ESDR; returns false when tokens are expired (and clears values)
    func checkAndRefreshEsdrTokens(expiresAt: Int, currentTime: Int, refreshToken: String, responseHandler: (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void ) -> Bool {
        if (currentTime >= expiresAt) {
            GlobalHandler.sharedInstance.esdrAccount.clear()
            GlobalHandler.sharedInstance.esdrLoginHandler.setUserLoggedIn(false)
            return false
        } else {
            requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
            return true
        }
    }
    
    
    func requestEsdrRefresh(refreshToken: String, responseHandler: (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void ) {
        // create request
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/oauth/token", httpMethod: "POST")
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
