//
//  EsdrLoginHandler.swift
//  AirPrototype
//
//  Created by mtasota on 12/18/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class EsdrLoginHandler {
    
    
    // MARK: singleton pattern; this is the only time the class should be initialized
    
    
    class var sharedInstance: EsdrLoginHandler {
        struct Singleton {
            static let instance = EsdrLoginHandler()
        }
        return Singleton.instance
    }
    
    
    // MARK: Class Functions
    
    
    func setUserLoggedIn(userLoggedIn: Bool) {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setBool(userLoggedIn, forKey: Constants.SettingsKeys.userLoggedIn)
        if userDefaults.synchronize() {
            SettingsHandler.sharedInstance.userLoggedIn = userLoggedIn
            // repopulates specks on successful login/logout
            GlobalHandler.sharedInstance.headerReadingsHashMap.populateSpecks()
            // also clears the blacklisted devices
            SettingsHandler.sharedInstance.clearBlacklistedDevices()
        }
    }
    
    
    func updateEsdrAccount(username: String, userId: Int, accessToken: String, refreshToken: String) {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setObject(username, forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(userId, forKey: Constants.SettingsKeys.userId)
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            SettingsHandler.sharedInstance.username = username
            SettingsHandler.sharedInstance.userId = userId
            SettingsHandler.sharedInstance.accessToken = accessToken
            SettingsHandler.sharedInstance.refreshToken = refreshToken
        }
    }
    
    
    func updateEsdrTokens(accessToken: String, refreshToken: String) {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            SettingsHandler.sharedInstance.accessToken = accessToken
            SettingsHandler.sharedInstance.refreshToken = refreshToken
        }
    }
    
    
    func removeEsdrAccount() {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.username], forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.accessToken], forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.refreshToken], forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            SettingsHandler.sharedInstance.username = nil
            SettingsHandler.sharedInstance.accessToken = nil
            SettingsHandler.sharedInstance.refreshToken = nil
            setUserLoggedIn(false)
        }
    }
    
}