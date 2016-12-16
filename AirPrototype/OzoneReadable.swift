//
//  OzoneReadable.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol OzoneReadable {
    
    var readableOzoneValue: AqiReadableValue? { get set }
    
    
    // returns a list of channels that influence the readable value
    func getOzoneChannels() -> Array<OzoneChannel>
    
    
    // return true if the Readable object has an Ozone value
    func hasReadableOzoneValue() -> Bool
    
    
    // return Ozone value
    func getReadableOzoneValue() -> AqiReadableValue

}
