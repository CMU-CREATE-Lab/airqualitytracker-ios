//
//  AirNowRequestHandler.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AirNowRequestHandler {
    
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as? AppDelegate)!
    }
    
    
    func requestAirNowObservation(location: Location, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void) ) {
        // generate safe URL
        let address = Constants.AirNow.API_URL + "/aq/observation/latLong/current/?format=application/json&distance=25&latitude=\(location.latitude)&longitude=\(location.longitude)&API_KEY=\(Constants.AppSecrets.AIR_NOW_API_KEY)"
        let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request, completionHandler: completionHandler)
    }
    
}