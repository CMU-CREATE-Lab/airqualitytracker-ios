//
//  TemperatureReadable.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol TemperatureReadable {
    
    var readableTemperatureValue: ReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getTemperatureChannels() -> Array<TemperatureChannel>
    
    
    // return true if the Readable object has a Temperature value
    func hasReadableTemperatureValue() -> Bool
    
    
    // return Temperature value
    func getReadableTemperatureValue() -> ReadableValue

}
