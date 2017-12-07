//
//  HumidityValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class HumidityValue: ReadableValue {
    
    fileprivate var value: Double
    var channel: Channel
    
    
    init(value: Double, humidityChannel: HumidityChannel) {
        self.value = value
        self.channel = humidityChannel
    }
    
    
    func getReadableUnits() -> String { return "%" }
    func getValue() -> Double { return value }
    
}
