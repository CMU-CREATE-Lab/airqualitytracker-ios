//
//  ServicesHandler.swift
//  AirPrototype
//
//  Created by mtasota on 9/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ServicesHandler {
//class ServicesHandler: CLLocationManagerDelegate {
    
    // singleton pattern; this is the only time the class should be initialized
    
    class var sharedInstance: ServicesHandler {
        struct Singleton {
            static let instance = ServicesHandler()
        }
        return Singleton.instance
    }
    
    // class variables/constructor
    
    var locationService = CLLocationSService()
    
    
    func startLocationService() {
        locationService.startLocationService()
    }

}