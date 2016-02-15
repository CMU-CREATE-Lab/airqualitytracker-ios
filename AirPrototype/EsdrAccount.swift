//
//  EsdrAccount.swift
//  AirPrototype
//
//  Created by mtasota on 2/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class EsdrAccount {
    
    var username: String?
    var userId: Int?
    var expiresAt: Int?
    var accessToken: String?
    var refreshToken: String?
    
    
    init(userDefaults: NSUserDefaults) {
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        userId = userDefaults.valueForKey(Constants.SettingsKeys.userId) as? Int
        expiresAt = userDefaults.valueForKey(Constants.SettingsKeys.expiresAt) as? Int
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func loadFromUserDefaults(userDefaults: NSUserDefaults) {
        username = userDefaults.valueForKey(Constants.SettingsKeys.username) as? String
        userId = userDefaults.valueForKey(Constants.SettingsKeys.userId) as? Int
        expiresAt = userDefaults.valueForKey(Constants.SettingsKeys.expiresAt) as? Int
        accessToken = userDefaults.valueForKey(Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.valueForKey(Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func clear() {
        username = nil
        userId = nil
        expiresAt = nil
        accessToken = nil
        refreshToken = nil
    }
    
}