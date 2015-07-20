//
//  AddressFeedsHashMap.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class AddressFeedsHashMap {
    
    var addresses = Array<SimpleAddress>()
    var gpsAddress: SimpleAddress?
    var hashMap = [SimpleAddress: Array<Feed>]()
    
    init() {
        gpsAddress = SimpleAddress()
        
        var temp: SimpleAddress = SimpleAddress()
        temp.name = "HELLO"
        addAddress(temp)
        temp = SimpleAddress()
        temp.name = "THERE"
        addAddress(temp)
    }
    
    
    // setGpsAddressLocation (waiting for location services to implement this)
    
    
    func removeAddress(simpleAddress: SimpleAddress) {
        hashMap.removeValueForKey(simpleAddress)
        // gh request addresses for display
    }
    
    
    func addAddress(simpleAddress: SimpleAddress) {
        var feed: Array<Feed> = pullFeedsForAddress(simpleAddress)
        put(simpleAddress, feeds: feed)
        // gh request addresses for display
    }
    
    
    func put(simpleAddress: SimpleAddress, feeds: Array<Feed>) {
        if let index = find(addresses, simpleAddress) {
            NSLog("address already exists at index=" + String(index))
        } else {
            addresses.append(simpleAddress)
        }
        hashMap[simpleAddress] = feeds
    }
    
    
    // getFeedsFromAddressInHashMap (not necessary since we have direct access to hashMap)
    
    
    func updateAddresses() {
        for address in addresses {
            self.put(address, feeds: pullFeedsForAddress(address))
        }
    }
    
    
    func pullFeedsForAddress(simpleAddress: SimpleAddress) -> Array<Feed> {
        // TODO
        var result = Array<Feed>()
        return result
    }
    
}