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
    
    func getMostRecentAirNowObservation() -> AirNowObservation
    func sortAirNowObservations()
}


extension AirNowReadable {
    
    
    func getMostRecentAirNowObservation() -> AirNowObservation {
        return airNowObservations[0]
    }
    
    
    func sortAirNowObservations() {
        // TODO sort list from newest to oldest; should call when adding new objects to list
    }
    
}