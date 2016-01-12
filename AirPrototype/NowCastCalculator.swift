//
//  NowCastCalculator.swift
//  AirPrototype
//
//  Created by mtasota on 1/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class NowCastCalculator {
    
    
    private static func computeWeightFactor(range: Double, max: Double) -> Double {
        var result: Double
        result = 1.0 - range/max
        if result < 0.5 {
            result = 0.5
        }
        return result
    }
    
    
    private static func summedWeightFactor(values: [Double], weightFactor: Double) -> Double {
        var result: Double
        result = 0
        for (index,element) in values.enumerate() {
            result += Double(index) * pow(element, Double(index))
        }
        return result
    }
    
    
    // ASSERT: NowCast is calculated from the last 12 hours, so hourlyValues should have size 12
    // ASSERT: hourlyValues does not contain nil values (note type [NSNumber!])
    // ASSERT: Ordered by hour (index 0 is most recent, index 11 is oldest)
    static func calculate(hourlyValues: [Double]) -> Double {
        // find min/max of list
        let max = hourlyValues.maxElement()!
        let min = hourlyValues.minElement()!
        // compute concentration range
        let range = max - min
        // compute the weight factor
        let weightFactor = computeWeightFactor(range,max: max)
        // sum the products of concentrations and weight factors
        let numerator = summedWeightFactor(hourlyValues, weightFactor: weightFactor)
        // sum of weight factors raised to the power
        let denominator = summedWeightFactor([1,1,1,1,1,1,1,1,1,1,1,1], weightFactor: weightFactor)
        // resulting value for NowCast
        let result = numerator/denominator
        return result
    }
    
    
    static func constructArrayFromHash(data: [Int: [Double]]) -> [Double] {
        var result = [Double]()

        // TODO bucket data into averaged 12-hour array
        // convert each averaged value into AQI
        
        return result
    }
    
}