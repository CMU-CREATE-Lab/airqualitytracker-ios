//
//  Scalable.swift
//  AirPrototype
//
//  Created by Mike Tasota on 6/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

enum ScaleType {
    case EPA_AQI, SPECK, WHO
}

protocol Scalable {
    
    func withinRange() -> Bool
    
    static func getIndexFromReading(reading: Double) -> Int
    
    func getRangeFromIndex() -> String
    
    func getColor() -> UIColor
    
    func getTitle() -> String
    
}