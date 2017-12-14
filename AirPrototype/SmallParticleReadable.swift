//
//  SmallParticleReadable.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 12/14/17.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

import Foundation

protocol SmallParticleReadable {
    
    var readableSmallParticleValue: ReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getSmallParticleChannels() -> Array<SmallParticleChannel>
    
    
    // return true if the Readable object has a value
    func hasReadableSmallParticleValue() -> Bool
    
    
    // return value
    func getReadableSmallParticleValue() -> ReadableValue
    
}
