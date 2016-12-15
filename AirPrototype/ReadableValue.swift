//
//  ReadableValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol ReadableValue {
    // returns the Channel that this value came from
    func getChannel() -> Channel
    
    // returns human-readable units that the value is measured in
    func getReadableUnits() -> String
    
    // return a value (this value should always be set)
    func getValue() -> Double
}
