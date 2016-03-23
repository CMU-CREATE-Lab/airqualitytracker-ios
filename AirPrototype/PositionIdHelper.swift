//
//  PositionIdHelper.swift
//  AirPrototype
//
//  Created by mtasota on 12/18/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class PositionIdHelper {
    
    
    private func setAddressLastPosition(position: Int) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.addressLastPosition)
        userDefaults.synchronize()
    }
    
    
    private func setSpeckLastPosition(position: Int) {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        userDefaults.setInteger(position, forKey: Constants.SettingsKeys.speckLastPosition)
        userDefaults.synchronize()
    }
    
    
    func getAdressLastPosition() -> Int? {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        let position = userDefaults.valueForKey(Constants.SettingsKeys.addressLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.addressLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func getSpeckLastPosition() -> Int? {
        let userDefaults = GlobalHandler.sharedInstance.settingsHandler.userDefaults
        let position = userDefaults.valueForKey(Constants.SettingsKeys.speckLastPosition) as! Int
        userDefaults.setInteger(position+1, forKey: Constants.SettingsKeys.speckLastPosition)
        if userDefaults.synchronize() {
            return position
        }
        return nil
    }
    
    
    func reorderAddressPositions(addresses: [SimpleAddress]) {
        var index = 1
        for address in addresses {
            address.positionId = index
            AddressDbHelper.updateAddressInDb(address)
            index += 1
        }
        setAddressLastPosition(index)
    }
    
    
    func reorderSpeckPositions(specks: [Speck]) {
        var index = 1
        for speck in specks {
            speck.positionId = index
            SpeckDbHelper.updateSpeckInDb(speck)
            index += 1
        }
        setSpeckLastPosition(index)
    }
    
}