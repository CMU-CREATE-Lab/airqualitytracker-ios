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
    
    
    func setUserLoggedIn(_ userLoggedIn: Bool) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.set(userLoggedIn, forKey: Constants.SettingsKeys.userLoggedIn)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.settingsHandler.userLoggedIn = userLoggedIn
            // repopulates specks on successful login/logout
            GlobalHandler.sharedInstance.readingsHandler.populateSpecks()
            // also clears the blacklisted devices
            GlobalHandler.sharedInstance.settingsHandler.clearBlacklistedDevices()
        }
    }
    
    
    func updateEsdrAccount(_ username: String, userId: Int, accessToken: String, refreshToken: String, expiresAt: Int) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.set(username, forKey: Constants.SettingsKeys.username)
        userDefaults.set(userId, forKey: Constants.SettingsKeys.userId)
        userDefaults.set(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.set(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        userDefaults.set(expiresAt, forKey: Constants.SettingsKeys.expiresAt)
        if userDefaults.synchronize() {
//            GlobalHandler.sharedInstance.esdrAccount.update(username, userId: userId, accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
            GlobalHandler.sharedInstance.esdrAccount.loadFromUserDefaults(userDefaults)
        }
    }
    
    
    func updateEsdrTokens(_ accessToken: String, refreshToken: String, expiresAt: Int) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.set(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.set(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        userDefaults.set(expiresAt, forKey: Constants.SettingsKeys.expiresAt)
        if userDefaults.synchronize() {
//            GlobalHandler.sharedInstance.esdrAccount.updateEsdrTokens(accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
            GlobalHandler.sharedInstance.esdrAccount.loadFromUserDefaults(userDefaults)
        }
    }
    
    
    func removeEsdrAccount() {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.set(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.username], forKey: Constants.SettingsKeys.username)
        userDefaults.set(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.accessToken], forKey: Constants.SettingsKeys.accessToken)
        userDefaults.set(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.refreshToken], forKey: Constants.SettingsKeys.refreshToken)
        userDefaults.set(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.expiresAt], forKey: Constants.SettingsKeys.expiresAt)
        if userDefaults.synchronize() {
            GlobalHandler.sharedInstance.esdrAccount.clear()
            setUserLoggedIn(false)
        }
    }
    
}
