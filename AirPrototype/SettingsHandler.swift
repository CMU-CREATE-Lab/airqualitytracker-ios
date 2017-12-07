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
    
    var userDefaults: UserDefaults
    var appUsesLocation: Bool
    var userLoggedIn: Bool
    var blacklistedDevices: [Int]?
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.shared.delegate! as? AppDelegate)!
        userDefaults = UserDefaults.standard
        userDefaults.register(defaults: Constants.DEFAULT_SETTINGS)
        // must declare in constructor since Swift is trash
        appUsesLocation = userDefaults.value(forKey: Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.value(forKey: Constants.SettingsKeys.userLoggedIn) as! Bool
        blacklistedDevices = userDefaults.value(forKey: Constants.SettingsKeys.blacklistedDevices) as? [Int]
    }
    
    
    func updateSettings() {
        appUsesLocation = userDefaults.value(forKey: Constants.SettingsKeys.appUsesLocation) as! Bool
        userLoggedIn = userDefaults.value(forKey: Constants.SettingsKeys.userLoggedIn) as! Bool
        GlobalHandler.sharedInstance.esdrAccount.loadFromUserDefaults(userDefaults)
        blacklistedDevices = userDefaults.value(forKey: Constants.SettingsKeys.blacklistedDevices) as? [Int]
    }
    
    
    func deviceIsBlacklisted(_ deviceId: Int) -> Bool {
        for id in blacklistedDevices! {
            if id == deviceId {
                return true
            }
        }
        return false
    }
    
    
    func addToBlacklistedDevices(_ deviceId: Int) {
        blacklistedDevices!.append(deviceId)
        userDefaults.set(blacklistedDevices, forKey: Constants.SettingsKeys.blacklistedDevices)
    }
    
    
    func clearBlacklistedDevices() {
        blacklistedDevices!.removeAll()
        userDefaults.set(blacklistedDevices, forKey: Constants.SettingsKeys.blacklistedDevices)
    }
    
    
    func setAppUsesCurrentLocation(_ value: Bool) {
        appUsesLocation = value
        userDefaults.set(value, forKey: Constants.SettingsKeys.appUsesLocation)
        if userDefaults.synchronize() {
            self.appUsesLocation = value
            GlobalHandler.sharedInstance.readingsHandler.refreshHash()
        }
    }
    
}
