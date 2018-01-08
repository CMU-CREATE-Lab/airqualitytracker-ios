//
//  LargeParticleValue.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 1/8/18.
//  Copyright © 2018 CMU Create Lab. All rights reserved.
//

import Foundation

class LargeParticleValue: ReadableValue {
    
    fileprivate var value: Double
    var channel: Channel
    
    
    init(value: Double, largeParticleChannel: LargeParticleChannel) {
        self.value = value
        self.channel = largeParticleChannel
    }
    
    
    func getReadableUnits() -> String { return "particles/ft^3" }
    func getValue() -> Double { return value }
    
}
