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
    private var channel: Pm25Channel
    
    
    init(value: Double, pm25Channel: Pm25Channel) {
        self.value = value
        self.channel = pm25Channel
    }
    
    
    func getChannel() -> Channel { return channel }
    func getReadableUnits() -> String { return "%" }
    func getValue() -> Double { return value }
    
}
