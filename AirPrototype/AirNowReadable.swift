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
    
    func getMostRecentAirNowObservation() -> AirNowObservation?
    mutating func appendAndSort(values: [AirNowObservation])
    
}


extension AirNowReadable {
    
    
    func getMostRecentAirNowObservation() -> AirNowObservation? {
        if airNowObservations.count > 0 {
            return airNowObservations[0]
        }
        return nil
    }
    
    
    mutating func appendAndSort(values: [AirNowObservation]) {
        airNowObservations.appendContentsOf(values)
        airNowObservations.sortInPlace {
            $0.observedDateTime.compare($1.observedDateTime) == NSComparisonResult.OrderedDescending
        }
    }
    
}