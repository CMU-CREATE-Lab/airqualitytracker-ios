//
//  HumidityReadable.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol HumidityReadable {
    
    var readableHumidityValue: ReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getHumidityChannels() -> Array<HumidityChannel>
    
    
    // return true if the Readable object has a Humidity value
    func hasReadableHumidityValue() -> Bool
    
    
    // return Humidity value
    func getReadableHumidityValue() -> ReadableValue

}
