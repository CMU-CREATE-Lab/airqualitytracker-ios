//
//  AirNowObservation.swift
//  AirPrototype
//
//  Created by mtasota on 2/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class AirNowObservation {
    
//    let dateFormat = NSDateFormatter()
//    dateFormat.dateFormat = "yyyy-dd-MM kk Z"
//    let input = ""
//    let date = dateFormat.dateFromString(input)
    // dateObserved,hourObserved,localTimeZone
    var observedDateTime: NSDate
    var readableDate: String
    var reportingArea: String
    var stateCode: String
    // TODO not sure what this location even represents... seems inconsistent with which feed values are reported
    var location: Location
    var parameterName: String
    var aqi: Double
    
    
    init(observedDateTime: NSDate, readableDate: String, reportingArea: String, stateCode: String, location: Location, parameterName: String, aqi: Double) {
        self.observedDateTime = observedDateTime
        self.readableDate = readableDate
        self.reportingArea = reportingArea
        self.stateCode = stateCode
        self.location = location
        self.parameterName = parameterName
        self.aqi = aqi
    }
    
}