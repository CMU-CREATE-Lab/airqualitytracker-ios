//
//  PositionIdHelper.swift
//  AirPrototype
//
//  Created by mtasota on 12/18/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class PositionIdHelper {
    
    
    // MARK: singleton pattern; this is the only time the class should be initialized
    
    
    class var sharedInstance: PositionIdHelper {
        struct Singleton {
            static let instance = PositionIdHelper()
        }
        return Singleton.instance
    }
    
    
    // MARK: Class Functions
    
    
    private func setAddressLastPosition(position: Int) {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.addressLastPosition)
        userDefaults.synchronize()
    }
    
    
    private func setSpeckLastPosition(position: Int) {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.speckLastPosition)
        userDefaults.synchronize()
    }
    
    
    func getAdressLastPosition() -> Int? {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        let position = userDefaults.valueForKey(Constants.SettingsKeys.addressLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.addressLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func getSpeckLastPosition() -> Int? {
        let userDefaults = SettingsHandler.sharedInstance.userDefaults
        let position = userDefaults.valueForKey(Constants.SettingsKeys.speckLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.speckLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func reorderAddressPositions(addresses: [SimpleAddress]) {
        // TODO this is slow; it could be sped up if we group the jobs together (so we only have to save/synchronize once)
        var index = 1
        for address in addresses {
            address.positionId = index
            AddressDbHelper.updateAddressInDb(address)
            index += 1
        }
        setAddressLastPosition(index)
    }
    
    
    func reorderSpeckPositions(specks: [Speck]) {
        // TODO this is slow; it could be sped up if we group the jobs together (so we only have to save/synchronize once)
        var index = 1
        for speck in specks {
            speck.positionId = index
            SpeckDbHelper.updateSpeckInDb(speck)
            index += 1
        }
        setSpeckLastPosition(index)
    }
    
}