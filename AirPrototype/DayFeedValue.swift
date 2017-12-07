//
//  DayFeedValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class DayFeedValue {
    
    enum DaysValueType {
        case mean, median, max
    }
    
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
    
    
    func getCount(_ type: DaysValueType) -> Double {
        switch type {
        case DaysValueType.mean:
            return mean;
        case DaysValueType.median:
            return median;
        case DaysValueType.max:
            return max;
        default:
            NSLog("ERROR - Undefined enum type.")
            return 0;
        }
    }
    
}
