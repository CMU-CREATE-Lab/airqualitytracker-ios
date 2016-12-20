//
//  GpsReadingHandler.swift
//  AirPrototype
//
//  Created by mtasota on 12/22/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class GpsReadingHandler {
    
    var gpsAddress: SimpleAddress

    
    init() {
        gpsAddress = SimpleAddress()
        gpsAddress.isCurrentLocation = true
        gpsAddress.name = "Loading Current Location"
        gpsAddress.location = Location(latitude: 0, longitude: 0)
    }
    
    
    func setGpsAddressLocation(location: Location) {
        gpsAddress.location = location
        GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(gpsAddress)
//        GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdateFeeds(gpsAddress)
    }
    
}
