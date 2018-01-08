//
//  SmallParticleValue.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 1/8/18.
//  Copyright © 2018 CMU Create Lab. All rights reserved.
//

import Foundation

class SmallParticleValue: ReadableValue {
    
    fileprivate var value: Double
    var channel: Channel
    
    
    init(value: Double, smallParticleChannel: SmallParticleChannel) {
        self.value = value
        self.channel = smallParticleChannel
    }
    
    
    func getReadableUnits() -> String { return "particles/ft^3" }
    func getValue() -> Double { return value }
    
}
