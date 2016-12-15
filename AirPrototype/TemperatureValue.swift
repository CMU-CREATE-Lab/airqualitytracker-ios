//
//  TemperatureValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class TemperatureValue: ReadableValue {
    
    private var value: Double
    private var channel: TemperatureChannel
    
    
    init(value: Double, temperatureChannel: TemperatureChannel) {
        self.value = value
        self.channel = temperatureChannel
    }
    
    
    func getChannel() -> Channel { return channel }
    func getReadableUnits() -> String { return "%" }
    func getValue() -> Double { return value }
    
}
