//
//  AirNowJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class AirNowJsonParser {
    
    
    private static func parseObservationFromJson(row: NSDictionary) -> AirNowObservation {
        var observation: AirNowObservation
        
        // parse
        let dateObserved = row.valueForKey("DateObserved") as! String
        let hourObserved = row.valueForKey("HourObserved") as! NSNumber
        let localTimeZone = row.valueForKey("LocalTimeZone") as! String
        let reportingArea = row.valueForKey("ReportingArea") as! String
        let stateCode = row.valueForKey("StateCode") as! String
        let lat = row.valueForKey("Latitude") as! NSNumber
        let long = row.valueForKey("Longitude") as! NSNumber
        let parameterName = row.valueForKey("ParameterName") as! String
        let aqi = row.valueForKey("AQI") as! NSNumber
        
        // intermediate objects
        let formattedString = "\(dateObserved) \(hourObserved) \(localTimeZone)"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H z"
        let time = dateFormatter.dateFromString(formattedString)
        let timeString = "\(hourObserved):00 \(localTimeZone)"
        let location = Location(latitude: Double(lat), longitude: Double(long))
        
        // return instance
        observation = AirNowObservation(observedDateTime: time!, readableDate: timeString, reportingArea: reportingArea, stateCode: stateCode, location: location, parameterName: parameterName, aqi: Double(aqi))
        return observation
    }
    
    
    static func parseObservationsFromJson(data: NSArray?) -> [AirNowObservation] {
        var result = [AirNowObservation]()
        
        // TODO "catch" API error
        for item in data! {
            let row = item as! NSDictionary
            result.append(parseObservationFromJson(row))
        }
        
        return result
    }
    
}