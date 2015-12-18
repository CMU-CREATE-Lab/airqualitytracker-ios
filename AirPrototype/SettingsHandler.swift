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
    
    
    // MARK: singleton pattern; this is the only time the class should be initialized
    
    
    class var sharedInstance: SettingsHandler {
        struct Singleton {
            static let instance = SettingsHandler()
        }
        return Singleton.instance
    }
    
    
    // MARK: Class Functions

    
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
    
    // PositionIdHandler
    //
    
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
    
    //
    // --
    
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
    
}