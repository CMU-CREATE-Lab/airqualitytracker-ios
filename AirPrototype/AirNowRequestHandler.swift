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
        appDelegate = (UIApplication.shared.delegate! as? AppDelegate)!
    }
    
    
    func requestAirNowObservation(_ readable: AirNowReadable) {
        var readable = readable
        // response handler
        func onAirNowObservationCompletionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSArray
                let result = AirNowJsonParser.parseObservationsFromJson(data)
                readable.appendAndSort(result)
                GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
            }
        }
        
        // make & send request
        let request = HttpHelper.generateRequest(Constants.AirNow.API_URL + "/aq/observation/latLong/current/?format=application/json&distance=25&latitude=\(readable.location.latitude)&longitude=\(readable.location.longitude)&API_KEY=\(Constants.AppSecrets.AIR_NOW_API_KEY)", httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendRequest(request as URLRequest, completionHandler: onAirNowObservationCompletionHandler)
    }
    
}
