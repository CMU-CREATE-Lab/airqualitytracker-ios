//
//  AirNowJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AirNowJsonParser {
    
    
    fileprivate static func parseObservationFromJson(_ row: NSDictionary) -> AirNowObservation {
        var observation: AirNowObservation
        
        // parse
        let dateObserved = row.value(forKey: "DateObserved") as! String
        let hourObserved = row.value(forKey: "HourObserved") as! NSNumber
        let localTimeZone = row.value(forKey: "LocalTimeZone") as! String
        let reportingArea = row.value(forKey: "ReportingArea") as! String
        let stateCode = row.value(forKey: "StateCode") as! String
        let lat = row.value(forKey: "Latitude") as! NSNumber
        let long = row.value(forKey: "Longitude") as! NSNumber
        let parameterName = row.value(forKey: "ParameterName") as! String
        let aqi = row.value(forKey: "AQI") as! NSNumber
        
        // intermediate objects
        let formattedString = "\(dateObserved) \(hourObserved) \(localTimeZone)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H z"
        let time = dateFormatter.date(from: formattedString)
        let timeString = "\(hourObserved):00 \(localTimeZone)"
        let location = Location(latitude: Double(lat), longitude: Double(long))
        
        // return instance
        observation = AirNowObservation(observedDateTime: time!, readableDate: timeString, reportingArea: reportingArea, stateCode: stateCode, location: location, parameterName: parameterName, aqi: Double(aqi))
        return observation
    }
    
    
    static func parseObservationsFromJson(_ data: NSArray?) -> [AirNowObservation] {
        var result = [AirNowObservation]()
        
        if data != nil {
            for item in data! {
                let row = item as! NSDictionary
                result.append(parseObservationFromJson(row))
            }
        } else {
            // "catch" parsing error (likely from API limit)
            NSLog("CAUGHT - Bad format for parseObservationsFromJson")
            DispatchQueue.main.async {
                UIAlertView.init(title: "AirNow Error", message: "Could not get latest reading from AirNow", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        
        return result
    }
    
}
