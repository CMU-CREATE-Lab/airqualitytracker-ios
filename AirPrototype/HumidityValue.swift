//
//  HumidityValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class HumidityValue: ReadableValue {
    
    private var value: Double
    private var channel: HumidityChannel
    
    
    init(value: Double, humidityChannel: HumidityChannel) {
        self.value = value
        self.channel = humidityChannel
    }
    
    
    func getChannel() -> Channel { return channel }
    func getReadableUnits() -> String { return "%" }
    func getValue() -> Double { return value }
    
}
