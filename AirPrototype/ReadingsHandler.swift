//
//  ReadingsHandler.swift
//  AirPrototype
//
//  Created by mtasota on 12/22/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class ReadingsHandler: ReadingsHandlerEditable {
    
    var gpsReadingHandler: GpsReadingHandler
    var adapterList = [String: [Readable]]()
    var adapterListTracker = [String: [Readable]]()
    
    
    init(appUsesLocation: Bool) {
        gpsReadingHandler = GpsReadingHandler()
        super.init()
        
        hashMap[headers[0]] = specks
        if appUsesLocation {
            var tempAddresses = [Readable]()
            tempAddresses.append(gpsReadingHandler.gpsAddress)
            for address in addresses {
                tempAddresses.append(address)
            }
            hashMap[headers[1]] = tempAddresses
        } else {
            hashMap[headers[1]] = addresses
        }
        // NOTICE: calling this hangs (since it tries to grab GlobalHandler.sharedInstance before it finishes init)
        // seems to work without it anyways, though
//        populateSpecks()
    }
    
    
    func populateAdapterList() {
        var items: [Readable]
        headers.removeAll(keepCapacity: true)
        
        
        adapterList.removeAll(keepCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            
            if header == Constants.HEADER_TITLES[1] && GlobalHandler.sharedInstance.settingsHandler.appUsesLocation {
                items.insert(gpsReadingHandler.gpsAddress, atIndex: 0)
                adapterList[header] = items
                headers.append(header)
            } else if items.count > 0 {
                adapterList[header] = items
                headers.append(header)
            }
        }
        
        adapterListTracker.removeAll(keepCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            if items.count > 0 {
                adapterListTracker[header] = items
            }
        }
    }
    
    
    override func refreshHash() {
        super.refreshHash()
        populateAdapterList()
        
        if GlobalHandler.singletonInstantiated {
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
    }
    
}