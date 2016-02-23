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
    
    
    func requestAirNowObservation(var readable: AirNowReadable) {
        // generate safe URL
        let address = Constants.AirNow.API_URL + "/aq/observation/latLong/current/?format=application/json&distance=25&latitude=\(readable.location.latitude)&longitude=\(readable.location.longitude)&API_KEY=\(Constants.AppSecrets.AIR_NOW_API_KEY)"
        let url = NSURL(string: address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // response handler
        func onAirNowObservationCompletionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSArray
                let result = AirNowJsonParser.parseObservationsFromJson(data)
                readable.appendAndSort(result)
            }
        }
        
        // create request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        // send request
        GlobalHandler.sharedInstance.httpRequestHandler.sendRequest(request, completionHandler: onAirNowObservationCompletionHandler)
    }
    
}