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
        case MEAN, MEDIAN, MAX
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
    
    
    func getCount(type: DaysValueType) -> Double {
        switch type {
        case DaysValueType.MEAN:
            return mean;
        case DaysValueType.MEDIAN:
            return median;
        case DaysValueType.MAX:
            return max;
        default:
            NSLog("ERROR - Undefined enum type.")
            return 0;
        }
    }
    
}
