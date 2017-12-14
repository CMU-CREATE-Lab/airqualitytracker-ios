//
//  LargeParticleReadable.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 12/14/17.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

import Foundation

protocol LargeParticleReadable {
    
    var readableLargeParticleValue: ReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getLargeParticleChannels() -> Array<LargeParticleChannel>
    
    
    // return true if the Readable object has a value
    func hasReadableLargeParticleValue() -> Bool
    
    
    // return value
    func getReadableLargeParticleValue() -> ReadableValue
    
}
