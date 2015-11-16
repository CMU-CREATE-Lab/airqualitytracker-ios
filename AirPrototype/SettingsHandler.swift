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
    var userId: Int?
    var accessToken: String?
    var refreshToken: String?
    var blacklistedDevices: [Int]?
    var appDelegate: AppDelegate
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
        userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults(Constants.DEFAULT_SETTINGS)
        // must declare in constructor since Swift is trash
        appUsesLocation = userDefaults.valueForKey(Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.valueForKey(Constants.SettingsKeys.userLoggedIn) as! Bool
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        userId = userDefaults.valueForKey(Constants.SettingsKeys.userId) as? Int
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
        blacklistedDevices = userDefaults.valueForKey(Constants.SettingsKeys.blacklistedDevices) as? [Int]
    }
    
    
    func updateSettings() {
        appUsesLocation = userDefaults.valueForKey(Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.valueForKey(Constants.SettingsKeys.userLoggedIn) as! Bool
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        userId = userDefaults.valueForKey(Constants.SettingsKeys.userId) as? Int
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
        blacklistedDevices = userDefaults.valueForKey(Constants.SettingsKeys.blacklistedDevices) as? [Int]
    }
    
    
    func getAdressLastPosition() -> Int? {
        let position = userDefaults.valueForKey(Constants.SettingsKeys.addressLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.addressLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func setAddressLastPosition(position: Int) {
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.addressLastPosition)
        userDefaults.synchronize()
    }
    
    
    func getSpeckLastPosition() -> Int? {
        let position = userDefaults.valueForKey(Constants.SettingsKeys.speckLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.speckLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func setSpeckLastPosition(position: Int) {
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.speckLastPosition)
        userDefaults.synchronize()
    }
    
    
    func deviceIsBlacklisted(deviceId: Int) -> Bool {
        for id in blacklistedDevices! {
            if id == deviceId {
                return true
            }
        }
        return false
    }
    
    
    func addToBlacklistedDevices(deviceId: Int) {
        blacklistedDevices!.append(deviceId)
        userDefaults.setObject(blacklistedDevices, forKey: Constants.SettingsKeys.blacklistedDevices)
    }
    
    
    func clearBlacklistedDevices() {
        blacklistedDevices!.removeAll()
        userDefaults.setObject(blacklistedDevices, forKey: Constants.SettingsKeys.blacklistedDevices)
    }
    
    
    func setAppUsesCurrentLocation(value: Bool) {
        appUsesLocation = value
        userDefaults.setBool(value, forKey: Constants.SettingsKeys.appUsesLocation)
        if userDefaults.synchronize() {
            self.appUsesLocation = value
            GlobalHandler.sharedInstance.headerReadingsHashMap.refreshHash()
        }
    }
    
    
    func setUserLoggedIn(userLoggedIn: Bool) {
        userDefaults.setBool(userLoggedIn, forKey: Constants.SettingsKeys.userLoggedIn)
        if userDefaults.synchronize() {
            self.userLoggedIn = userLoggedIn
            // repopulates specks on successful login/logout
            GlobalHandler.sharedInstance.headerReadingsHashMap.populateSpecks()
            // also clears the blacklisted devices
            self.clearBlacklistedDevices()
        }
    }
    
    
    func updateEsdrAccount(username: String, userId: Int, accessToken: String, refreshToken: String) {
        userDefaults.setObject(username, forKey: Constants.SettingsKeys.username)
        userDefaults.setObject(userId, forKey: Constants.SettingsKeys.userId)
        userDefaults.setObject(accessToken, forKey: Constants.SettingsKeys.accessToken)
        userDefaults.setObject(refreshToken, forKey: Constants.SettingsKeys.refreshToken)
        if userDefaults.synchronize() {
            self.username = username
            self.userId = userId
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
            setUserLoggedIn(false)
        }
    }
    
}