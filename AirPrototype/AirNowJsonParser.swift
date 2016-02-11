//
//  AirNowJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class AirNowJsonParser {
    
    
    private static func parseObservationFromJson() -> AirNowObservation {
        var observation: AirNowObservation
        
        // TODO parse
        let time = NSDate()
        let reportingArea = ""
        let stateCode = ""
        let location = Location(latitude: 0, longitude: 0)
        let parameterName = ""
        let aqi = 0.0
        
        observation = AirNowObservation(observedDateTime: time, reportingArea: reportingArea, stateCode: stateCode, location: location, parameterName: parameterName, aqi: aqi)
        
        return observation
    }
    
    
    static func parseObservationsFromJson() -> [AirNowObservation] {
        let result = [AirNowObservation]()
        
        // TODO parse json
        
        return result
    }
    
}