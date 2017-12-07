//
//  EsdrAuthHandler.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class EsdrAuthHandler {
    
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.shared.delegate! as? AppDelegate)!
    }
    
    
    func requestEsdrToken(_ username: String, password: String, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/oauth/token", httpMethod: "POST")
        let params:[String: String] = [
            "grant_type": Constants.Esdr.GRANT_TYPE_TOKEN,
            "client_id": Constants.AppSecrets.ESDR_CLIENT_ID,
            "client_secret": Constants.AppSecrets.ESDR_CLIENT_SECRET,
            "username": username,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
    }
    
    
    func requestEsdrRefresh(_ refreshToken: String, responseHandler: @escaping (_ url: URL?, _ response: URLResponse?, _ error: Error?) -> Void ) {
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
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: responseHandler)
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
