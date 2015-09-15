//
//  HeaderReadingsHashMap.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class HeaderReadingsHashMap {
    
    var gpsAddress: SimpleAddress
    var addresses = Array<SimpleAddress>()
    var specks = Array<Speck>()
    var headers = Constants.HEADER_TITLES
    var hashMap = [String: Array<Readable>]()
    // (Android only) adapterList
    init() {
        gpsAddress = SimpleAddress()
        // TODO remove hardcoded location
        gpsAddress.location = Location(latitude: 40.377384, longitude: -79.892563)
//        gpsAddress.requestUpdateFeeds()
    }
    
    
//    // (Android only)
//    func populateAdapterList() {
//        
//    }
    
    
    // required helpers to get the index since find() does not properly
    // match objects that should be equivalent.
    private func findIndexFromAddress(address: SimpleAddress) -> Int? {
        let max = addresses.endIndex
        for i in 0...max {
            if addresses[i] === address {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from address")
        return nil
    }
    private func findIndexFromSpeck(speck: Speck) -> Int? {
        let max = specks.endIndex
        for i in 0...max {
            if specks[i] === speck {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from speck")
        return nil
    }
    
    
    func setGpsAddressLocation(location: Location) {
        gpsAddress.location = location
        gpsAddress.requestUpdateFeeds()
    }
    
    
    func addReading(readable: Readable) {
        let type = readable.getReadableType()
        switch type {
        case ReadableType.ADDRESS:
            addresses.append(readable as! SimpleAddress)
        case ReadableType.SPECK:
            specks.append(readable as! Speck)
        default:
            NSLog("Tried to add Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    func removeReading(readable: Readable) {
        let type = readable.getReadableType()
        switch type {
        case ReadableType.ADDRESS:
            if let index = findIndexFromAddress(readable as! SimpleAddress) {
                addresses.removeAtIndex(index)
                NSLog("1..")
            }
            NSLog("..2")
        case ReadableType.SPECK:
            if let speckIndex = findIndexFromSpeck(readable as! Speck) {
                specks.removeAtIndex(speckIndex)
            }
        default:
            NSLog("Tried to remove Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    func updateAddresses() {
        for address in addresses {
            address.requestUpdateFeeds()
        }
    }
    
    
    func updateSpecks() {
        for speck in specks {
            speck.requestUpdate()
        }
    }
    
    
    func populateSpecks() {
        specks.removeAll(keepCapacity: true)
        if SettingsHandler.sharedInstance.userLoggedIn {
            func completionHandler(url: NSURL!, response: NSURLResponse!, error: NSError!) {
                var feeds: Array<Feed>
                let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as? NSDictionary
                feeds = JsonParser.populateAllFeedsFromJson(data!)
                for feed in feeds {
                    var speck = Speck(feed: feed)
                    specks.append(speck)
                    speck.requestUpdate()
                }
            }
            HttpRequestHandler.sharedInstance.requestPrivateFeeds("", completionHandler: completionHandler)
        }
    }
    
    
    func refreshHash() {
        hashMap.removeAll(keepCapacity: true)
        hashMap[headers[0]] = specks
        if SettingsHandler.sharedInstance.appUsesLocation {
            var tempAddresses = [Readable]()
            tempAddresses.append(gpsAddress)
            for address in addresses {
                tempAddresses.append(address)
            }
            hashMap[headers[1]] = tempAddresses
        } else {
            hashMap[headers[1]] = addresses
        }
        GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
    }
    
}