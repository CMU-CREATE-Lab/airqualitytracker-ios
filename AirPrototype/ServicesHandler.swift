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
    
    var locationService = CLLocationSService()
    
    
    func startLocationService() {
        locationService.startLocationService()
    }

}