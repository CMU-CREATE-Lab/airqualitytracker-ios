//
//  Pm25Readable.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol Pm25Readable {
    
    var readablePm25Value: AqiReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getPm25Channels() -> Array<Pm25Channel>
    
    
    // return true if the Readable object has a PM2.5 value
    func hasReadablePm25Value() -> Bool
    
    
    // return PM2.5 value
    func getReadablePm25Value() -> AqiReadableValue
    
}
