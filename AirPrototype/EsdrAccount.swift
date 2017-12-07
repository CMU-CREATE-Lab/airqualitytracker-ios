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
    
    
    init(userDefaults: UserDefaults) {
        username = userDefaults.value(forKey: Constants.SettingsKeys.username) as? String
        userId = userDefaults.value(forKey: Constants.SettingsKeys.userId) as? Int
        expiresAt = userDefaults.value(forKey: Constants.SettingsKeys.expiresAt) as? Int
        accessToken = userDefaults.value(forKey: Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.value(forKey: Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func loadFromUserDefaults(_ userDefaults: UserDefaults) {
        username = userDefaults.value(forKey: Constants.SettingsKeys.username) as? String
        userId = userDefaults.value(forKey: Constants.SettingsKeys.userId) as? Int
        expiresAt = userDefaults.value(forKey: Constants.SettingsKeys.expiresAt) as? Int
        accessToken = userDefaults.value(forKey: Constants.SettingsKeys.accessToken) as? String
        refreshToken = userDefaults.value(forKey: Constants.SettingsKeys.refreshToken) as? String
    }
    
    
    func clear() {
        username = nil
        userId = nil
        expiresAt = nil
        accessToken = nil
        refreshToken = nil
    }
    
}
