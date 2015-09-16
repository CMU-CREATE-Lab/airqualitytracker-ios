//
//  SettingsHandler.swift
//  AirPrototype
//
//  Created by mtasota on 9/4/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SettingsHandler {
    
    // singleton pattern; this is the only time the class should be initialized
    
    class var sharedInstance: SettingsHandler {
        struct Singleton {
            static let instance = SettingsHandler()
        }
        return Singleton.instance
    }
    
    // class variables/constructor
    
    var userDefaults: NSUserDefaults
    var appUsesLocation: Bool
    var userLoggedIn: Bool
    var username: String?
    var accessToken: String?
    var refreshToken: String?
    var appDelegate: AppDelegate
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
        userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults(Constants.DEFAULT_SETTINGS)
        // must declare in constructor since Swift is trash
        appUsesLocation = userDefaults.valueForKey(Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.valueForKey(Constants.SettingsKeys.userLoggedIn) as! Bool
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func updateSettings() {
        appUsesLocation = userDefaults.valueForKey(Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.valueForKey(Constants.SettingsKeys.userLoggedIn) as! Bool
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func setAppUsesCurrentLocation(value: Bool) {
        appUsesLocation = value
        userDefaults.setBool(value, forKey: Constants.SettingsKeys.appUsesLocation)
        if userDefaults.synchronize() {
            self.appUsesLocation = value
            GlobalHandler.sharedInstance.updateReadings()
        }
    }
    
    
    func setUserLoggedIn(userLoggedIn: Bool) {
        userDefaults.setBool(userLoggedIn, forKey: Constants.SettingsKeys.userLoggedIn)
        if userDefaults.synchronize() {
            self.userLoggedIn = userLoggedIn
            // repopulates specks on successful login/logout
            GlobalHandler.sharedInstance.headerReadingsHashMap.populateSpecks()
        }
    }
    
    
    func updateEsdrAccount(username: String, accessToken: String, refreshToken: String) {
        userDefaults.setObject(username, forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            self.username = username
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
    
    
    func updateEsdrTokens(accessToken: String, refreshToken: String) {
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
    
    
    func removeEsdrAccount() {
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.username], forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.accessToken], forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(Constants.DEFAULT_SETTINGS[Constants.SettingsKeys.refreshToken], forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            self.username = nil
            self.accessToken = nil
            self.refreshToken = nil
        }
    }
    
}