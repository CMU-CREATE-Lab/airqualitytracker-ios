//
//  ReadableValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

enum ReadableValueType {
    case instantcast, nowcast
}

protocol ReadableValue {
    
    var channel: Channel { get set }
    
    
    // returns human-readable units that the value is measured in
    func getReadableUnits() -> String
    
    // return a value (this value should always be set)
    func getValue() -> Double
    
}
