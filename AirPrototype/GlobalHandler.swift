//
//  GlobalHandler.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GlobalHandler {
    var appDelegate: AppDelegate
    var headerReadingsHashMap: HeaderReadingsHashMap
    
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as! AppDelegate)
        headerReadingsHashMap = HeaderReadingsHashMap()
    }
    // singleton pattern; this is the only time the class should be initialized
    class var sharedInstance: GlobalHandler {
        struct Singleton {
            static let instance = GlobalHandler()
        }
        return Singleton.instance
    }
    
    
    // TODO global stuff
    
    
    func updateReadings() {
        headerReadingsHashMap.updateAddresses()
        headerReadingsHashMap.updateSpecks()
        if SettingsHandler.sharedInstance.appUsesLocation {
            // TODO location services
        }
    }
    
    
    func requestAddressesForDisplay() -> Array<SimpleAddress> {
        return headerReadingsHashMap.addresses
    }
}