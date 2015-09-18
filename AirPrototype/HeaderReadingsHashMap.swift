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
    var adapterList = [String: [Readable]]()
    init() {
        gpsAddress = SimpleAddress()
        gpsAddress.isCurrentLocation = true
        gpsAddress.name = "Loading Current Location"
        gpsAddress.location = Location(latitude: 0, longitude: 0)
        
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
        populateSpecks()
    }
    
    
//    // (Android only)
//    func populateAdapterList() {
//        
//    }
    func populateAdapterList() {
        var items: [Readable]
//        var newHeaders = [String]()
        headers.removeAll(keepCapacity: true)
        
        adapterList.removeAll(keepCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            if items.count > 0 {
                adapterList[header] = items
//                newHeaders.append(header)
                headers.append(header)
            }
        }
//        headers = newHeaders
    }
    
    
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
                refreshHash()
            }
            let authToken = SettingsHandler.sharedInstance.accessToken
            let userId = SettingsHandler.sharedInstance.userId
            HttpRequestHandler.sharedInstance.requestSpecks(authToken!, userId: userId!, completionHandler: completionHandler)
        }
        refreshHash()
    }
    
    
    func refreshHash() {
        var tempReadables: [Readable]
        hashMap.removeAll(keepCapacity: true)
        
        // specks
        if specks.count > 0 {
            tempReadables = [Readable]()
            for speck in specks {
                tempReadables.append(speck)
            }
            hashMap[Constants.HEADER_TITLES[0]] = tempReadables
        } else {
            hashMap[Constants.HEADER_TITLES[0]] = specks
        }
        
        // cities
        tempReadables = [Readable]()
        if SettingsHandler.sharedInstance.appUsesLocation {
            tempReadables.append(gpsAddress)
            gpsAddress.requestUpdateFeeds()
        }
        for address in addresses {
            tempReadables.append(address)
        }
        hashMap[Constants.HEADER_TITLES[1]] = tempReadables
        
        populateAdapterList()
        
        if GlobalHandler.singletonInstantiated {
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
    }
    
}