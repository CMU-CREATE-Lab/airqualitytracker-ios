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
    
    
    func requestEsdrRefresh(refreshToken: String, responseHandler: (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void ) {
        if !Constants.REFRESHES_ESDR_TOKEN {
            NSLog("WARNING: requested ESDR refresh but REFRESHES_ESDR_TOKEN is not set.")
            return
        }
        
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
    
    
    // Alert the user that their account has been logged out and will be prompted to re-enter username/password
    func alertLogout() -> Bool {
        let globalHandler = GlobalHandler.sharedInstance
        if globalHandler.settingsHandler.userLoggedIn && globalHandler.esdrAccount.expiresAt <= 0 {
            globalHandler.esdrLoginHandler.removeEsdrAccount()
            return true
        }
        return false
    }
    
}
