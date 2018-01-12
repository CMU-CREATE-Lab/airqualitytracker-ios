//
//  ReadingsHandlerEditable.swift
//  AirPrototype
//
//  Created by mtasota on 12/22/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class ReadingsHandlerEditable: ReadingsHandlerCore {
    
    
    // required helpers to get the index since find() does not properly
    // match objects that should be equivalent.
    fileprivate func findIndexFromAddress(_ address: SimpleAddress) -> Int? {
        let max = addresses.endIndex - 1
        for i in 0...max {
            if addresses[i] === address {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from address")
        return nil
    }
    
    
    fileprivate func findIndexFromSpeck(_ speck: Speck) -> Int? {
        let max = specks.endIndex - 1
        for i in 0...max {
            if specks[i] === speck {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from speck")
        return nil
    }
    
    
    fileprivate func findIndexFromHoneybee(_ honeybee: Honeybee) -> Int? {
        let max = honeybees.endIndex - 1
        for i in 0...max {
            if honeybees[i] === honeybee {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from honeybee")
        return nil
    }

    
    func reorderReading(_ reading: Readable, destination: Readable) {
        if (reading is SimpleAddress) {
            let from = findIndexFromAddress(reading as! SimpleAddress)
            let to = findIndexFromAddress(destination as! SimpleAddress)
            addresses.remove(at: from!)
            addresses.insert(reading as! SimpleAddress, at: to!)
        } else if (reading is Speck) {
            let from = findIndexFromSpeck(reading as! Speck)
            let to = findIndexFromSpeck(destination as! Speck)
            specks.remove(at: from!)
            specks.insert(reading as! Speck, at: to!)
        } else if (reading is Honeybee) {
            let from = findIndexFromHoneybee(reading as! Honeybee)
            let to = findIndexFromHoneybee(destination as! Honeybee)
            honeybees.remove(at: from!)
            honeybees.insert(reading as! Honeybee, at: to!)
        }
        let positionIdHelper = GlobalHandler.sharedInstance.positionIdHelper
        positionIdHelper.reorderAddressPositions(addresses)
        positionIdHelper.reorderSpeckPositions(specks)
        refreshHash()
    }
    
    
    func removeReading(_ readable: Readable) {
        if (readable is SimpleAddress) {
            if let index = findIndexFromAddress(readable as! SimpleAddress) {
                addresses.remove(at: index)
            }
            AddressDbHelper.deleteAddressFromDb(readable as! SimpleAddress)
        } else if (readable is Speck) {
            if let speckIndex = findIndexFromSpeck(readable as! Speck) {
                specks.remove(at: speckIndex)
            }
            let speck = readable as! Speck
            SpeckDbHelper.deleteSpeckFromDb(speck)
            GlobalHandler.sharedInstance.settingsHandler.addToBlacklistedDevices(speck.deviceId)
        } else if (readable is Honeybee) {
            if let honeybeeIndex = findIndexFromHoneybee(readable as! Honeybee) {
                honeybees.remove(at: honeybeeIndex)
            }
            let honeybee = readable as! Honeybee
            HoneybeeDbHelper.deleteHoneybeeFromDb(honeybee)
            GlobalHandler.sharedInstance.settingsHandler.addToBlacklistedDevices(honeybee.deviceId)
        } else {
            NSLog("Tried to remove Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    func renameReading(_ reading: Readable, name: String) {
        if (reading is SimpleAddress) {
            let address = reading as! SimpleAddress
            address.name = name
            AddressDbHelper.updateAddressInDb(address)
        } else if (reading is Speck) {
            let speck = reading as! Speck
            speck.name = name
            SpeckDbHelper.updateSpeckInDb(speck)
        } else if (reading is Honeybee) {
            let honeybee = reading as! Honeybee
            honeybee.name = name
            HoneybeeDbHelper.updateHoneybeeInDb(honeybee)
        } else {
            NSLog("WARNING - could not rename reading to \(name) from unknown class")
        }
    }
    
}
