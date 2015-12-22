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
    
    
    func setUserLoggedIn(userLoggedIn: Bool) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setBool(userLoggedIn, forKey: Constants.SettingsKeys.userLoggedIn)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.settingsHandler.userLoggedIn = userLoggedIn
            // repopulates specks on successful login/logout
            GlobalHandler.sharedInstance.readingsHandler.populateSpecks()
            // also clears the blacklisted devices
            GlobalHandler.sharedInstance.settingsHandler.clearBlacklistedDevices()
        }
    }
    
    
    func updateEsdrAccount(username: String, userId: Int, accessToken: String, refreshToken: String) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setObject(username, forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(userId, forKey: Constants.SettingsKeys.userId)
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.settingsHandler.username = username
            GlobalHandler.sharedInstance.settingsHandler.userId = userId
            GlobalHandler.sharedInstance.settingsHandler.accessToken = accessToken
            GlobalHandler.sharedInstance.settingsHandler.refreshToken = refreshToken
        }
    }
    
    
    func updateEsdrTokens(accessToken: String, refreshToken: String) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.settingsHandler.accessToken = accessToken
            GlobalHandler.sharedInstance.settingsHandler.refreshToken = refreshToken
        }
    }
    
    
    func removeEsdrAccount() {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.username], forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.accessToken], forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.refreshToken], forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.settingsHandler.username = nil
            GlobalHandler.sharedInstance.settingsHandler.accessToken = nil
            GlobalHandler.sharedInstance.settingsHandler.refreshToken = nil
            setUserLoggedIn(false)
        }
    }
    
}