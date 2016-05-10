//
//  DayFeedValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class DayFeedValue {
    
    var time: Int
    var mean: Double
    var median: Double
    var max: Double
    
    
    init(time: Int, mean: Double, median: Double, max: Double) {
        self.time = time
        self.mean = mean
        self.median = median
        self.max = max
    }
    
}
