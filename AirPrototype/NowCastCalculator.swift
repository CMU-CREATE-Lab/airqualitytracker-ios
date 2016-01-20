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
            result += element * pow(weightFactor, Double(index))
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
    
    
    static func constructArrayFromHash(data: [Int: [Double]], currentTime: Int) -> [Double] {
        var result = [Double](arrayLiteral: 0,0,0,0,0,0,0,0,0,0,0,0)
        var tempResult = [[Double]](arrayLiteral: [],[],[],[],[],[],[],[],[],[],[],[])

        // bucket data into averaged 12-hour array
        for keyTime in data.keys {
            let index = (currentTime - keyTime) / 3600
            let value = data[keyTime]![0]
            let count = data[keyTime]![1]
            if tempResult[index].count > 0 {
                tempResult[index][0] += value*count
                tempResult[index][1] += count
            } else {
                tempResult[index] = [value*count,count]
            }
        }
        
        var firstNonempty: Int?
        var firstValue: Double?
        for (index,element) in tempResult.enumerate() {
            if element.count > 0 && element[1] > 0 {
                firstNonempty = index
                firstValue = element[0]/element[1]
                break
            }
        }
        if firstNonempty == nil {
            return []
        }
        NSLog("firstNonempty=\(firstNonempty!)")
        var lastValue = firstValue!
        for (index,element) in tempResult.enumerate() {
            if index <= firstNonempty! {
                // set all values to be the same as the first nonempty value
                result[index] = firstValue!
            } else if element.count > 0 && element[1] > 0 {
                // next, populate each hour with values from the data
                let currentValue = element[0]/element[1]
                result[index] = currentValue
                lastValue = currentValue
            } else {
                // when data is missing a value, use the same value as the last value that was used
                NSLog("Value missing at index=\(index)")
                result[index] = lastValue
            }
        }
        
        return result
    }
    
}