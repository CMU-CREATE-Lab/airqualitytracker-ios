//
//  TemperatureValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class TemperatureValue: ReadableValue {
    
    fileprivate var value: Double
    var channel: Channel
    
    
    init(value: Double, temperatureChannel: TemperatureChannel) {
        self.value = value
        self.channel = temperatureChannel
    }
    
    
    func getReadableUnits() -> String { return "°C" }
    func getValue() -> Double { return value }
    
}
