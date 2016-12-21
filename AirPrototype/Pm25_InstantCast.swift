//
//  Pm25_InstantCast.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class Pm25_InstantCast: Pm25AqiReadableValue {
    
    private var value: Double
    var channel: Channel
    
    
    init(value: Double, pm25Channel: Pm25Channel) {
        self.value = value
        self.channel = pm25Channel
    }
    
    
    func getReadableUnits() -> String { return "%" }
    func getValue() -> Double { return value }
    
}
