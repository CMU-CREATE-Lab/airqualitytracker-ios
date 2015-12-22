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
    private func findIndexFromAddress(address: SimpleAddress) -> Int? {
        let max = addresses.endIndex - 1
        for i in 0...max {
            if addresses[i] === address {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from address")
        return nil
    }
    
    
    private func findIndexFromSpeck(speck: Speck) -> Int? {
        let max = specks.endIndex - 1
        for i in 0...max {
            if specks[i] === speck {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from speck")
        return nil
    }

    
    func reorderReading(reading: Readable, destination: Readable) {
        if reading.getReadableType() == destination.getReadableType() {
            if reading.getReadableType() == ReadableType.ADDRESS {
                let from = findIndexFromAddress(reading as! SimpleAddress)
                let to = findIndexFromAddress(destination as! SimpleAddress)
                addresses.removeAtIndex(from!)
                addresses.insert(reading as! SimpleAddress, atIndex: to!)
            } else if reading.getReadableType() == ReadableType.SPECK {
                let from = findIndexFromSpeck(reading as! Speck)
                let to = findIndexFromSpeck(destination as! Speck)
                specks.removeAtIndex(from!)
                specks.insert(reading as! Speck, atIndex: to!)
            }
            let positionIdHelper = GlobalHandler.sharedInstance.positionIdHelper
            positionIdHelper.reorderAddressPositions(addresses)
            positionIdHelper.reorderSpeckPositions(specks)
            refreshHash()
        }
    }
    
    
    func removeReading(readable: Readable) {
        let type = readable.getReadableType()
        switch type {
        case ReadableType.ADDRESS:
            if let index = findIndexFromAddress(readable as! SimpleAddress) {
                addresses.removeAtIndex(index)
            }
        case ReadableType.SPECK:
            if let speckIndex = findIndexFromSpeck(readable as! Speck) {
                specks.removeAtIndex(speckIndex)
            }
        default:
            NSLog("Tried to remove Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    func renameReading(reading: Readable, name: String) {
        if reading.getReadableType() == ReadableType.ADDRESS {
            let address = reading as! SimpleAddress
            address.name = name
            AddressDbHelper.updateAddressInDb(address)
        } else if reading.getReadableType() == ReadableType.SPECK {
            let speck = reading as! Speck
            speck.name = name
            SpeckDbHelper.updateSpeckInDb(speck)
        }
    }
    
}