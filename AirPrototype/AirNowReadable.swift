//
//  AirNowReadable.swift
//  AirPrototype
//
//  Created by mtasota on 2/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol AirNowReadable: Readable {
    
    var location: Location {get set}
    var airNowObservations: [AirNowObservation] {get set}
    
    func getMostRecentAirNowObservations() -> [AirNowObservation]
    func requestAirNow()
    mutating func appendAndSort(values: [AirNowObservation])
    
}


extension AirNowReadable {
    
    
    func getMostRecentAirNowObservations() -> [AirNowObservation] {
        var values = [AirNowObservation]()
        if airNowObservations.count > 0 {
            let date = airNowObservations[0].observedDateTime
            for observation in airNowObservations {
                if observation.observedDateTime.compare(date) == NSComparisonResult.OrderedSame {
                    values.append(observation)
                }
            }
        }
        return values
    }
    
    
    func requestAirNow() {
        GlobalHandler.sharedInstance.airNowRequestHandler.requestAirNowObservation(self)
    }
    
    
    mutating func appendAndSort(values: [AirNowObservation]) {
        airNowObservations.appendContentsOf(values)
        airNowObservations.sortInPlace {
            $0.observedDateTime.compare($1.observedDateTime) == NSComparisonResult.OrderedDescending
        }
    }
    
}