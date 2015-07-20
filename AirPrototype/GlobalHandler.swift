//
//  GlobalHandler.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class GlobalHandler {
    var appDelegate: AppDelegate
    var addressFeedsHashMap: AddressFeedsHashMap
    var addressList = Array<SimpleAddress>()
    
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
        addressFeedsHashMap = AddressFeedsHashMap()
        
        var temp: SimpleAddress = SimpleAddress()
        temp.name = "HELLO"
        addressList.append(temp)
        temp = SimpleAddress()
        temp.name = "THERE"
        addressList.append(temp)
    }
    // singleton pattern; this is the only time the class should be initialized
    class var sharedInstance: GlobalHandler {
        struct Singleton {
            static let instance = GlobalHandler()
        }
        return Singleton.instance
    }
    
    
    // TODO global stuff
    func requestAddressesForDisplay() -> Array<SimpleAddress> {
        return addressList
    }
}