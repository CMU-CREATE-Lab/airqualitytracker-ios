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
    
    
    override init() {
        gpsReadingHandler = GpsReadingHandler()
        super.init()
        
        hashMap[headers[0]] = specks
        hashMap[headers[1]] = addresses
    }
    
    
    func populateAdapterList() {
        var items: [Readable]
        headers.removeAll(keepingCapacity: true)
        
        
        adapterList.removeAll(keepingCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            
            if header == Constants.HEADER_TITLES[1] && GlobalHandler.sharedInstance.settingsHandler.appUsesLocation {
                items.insert(gpsReadingHandler.gpsAddress, at: 0)
                adapterList[header] = items
                headers.append(header)
            } else if items.count > 0 {
                adapterList[header] = items
                headers.append(header)
            }
        }
        
        adapterListTracker.removeAll(keepingCapacity: true)
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
