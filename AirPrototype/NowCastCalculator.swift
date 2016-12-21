//
//  NowCastCalculator.swift
//  AirPrototype
//
//  Created by mtasota on 1/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class NowCastCalculator {
    
    var hours: Int
    var weightType: WeightType
    
    enum WeightType {
        case RATIO, PIECEWISE
    }
    
    struct TimeValue {
        var count: Int
        var value: Double
    }
    
    
    init(hours: Int, weightType: WeightType) {
        self.hours = hours
        self.weightType = weightType
    }
    
    
    private func computeWeightFactor(range: Double, max: Double) -> Double {
        var result: Double
        
        // avoid division by zero
        if max == 0 {
            NSLog("NowCastCalculator.computeWeightFactor has a max of 0; setting weight factor to 0")
            result = 0.0
        } else {
            result = 1.0 - range/max
        }
        
        // piecewise weight type has a minimum weight factor of 1/2
        if self.weightType == WeightType.PIECEWISE && result < 0.5 {
            result = 0.5
        }
        
        return result
    }
    
    
    private func summedWeightFactor(values: [Double], weightFactor: Double) -> Double {
        var result: Double
        result = 0
        for (index,element) in values.enumerate() {
            result += element * pow(weightFactor, Double(index))
        }
        return result
    }
    
    
    // ASSERT: NowCast is calculated from a 12 hour range, so hourlyValues should have size 12
    // ASSERT: hourlyValues does not contain nil values
    // ASSERT: Ordered by hour (index 0 is most recent, index 11 is oldest)
    func calculate(hourlyValues: [Double]) -> Double {
        if hourlyValues.count == 0 {
            NSLog("WARNING - tried NowCastCalculator.calculate with an empty array; returning 0")
            return 0
        }
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
        var oneVector = [Double]()
        for _ in 1...self.hours {
            oneVector.append(1)
        }
        let denominator = summedWeightFactor(oneVector, weightFactor: weightFactor)
        // resulting value for NowCast
        let result = numerator/denominator
        return result
    }
    
    
    func constructArrayFromHash(data: [Int: [Double]], currentTime: Int) -> [Double] {
        var result = [Double]()
        var tempResult = [TimeValue?]()
        for _ in 0...self.hours {
            result.append(0)
            tempResult.append(nil)
        }
        
        // bucket data into averaged hourly array
        for keyTime in data.keys {
            let index = (currentTime - keyTime) / 3600
            //  skip any keys that are outside the hours we care about
            if index > self.hours { continue }
            let value = data[keyTime]![0]
            let count = Int(floor(data[keyTime]![1]))
            if let timeValue = tempResult[index] {
                tempResult[index] = TimeValue(count: timeValue.count + count, value: timeValue.value + value*Double(count))
            } else {
                tempResult[index] = TimeValue(count: count, value: value*Double(count))
            }
        }
        
        // Handle finding first non-empty value; return if entire array is empty
        var firstNonempty: Int?
        var firstValue: Double?
        for (index,_) in tempResult.enumerate() {
            if let element = tempResult[index] {
                if element.count > 0 && element.value > 0 {
                    firstNonempty = index
                    firstValue = element.value/Double(element.count)
                    break
                }
            }
        }
        if firstNonempty == nil {
            return []
        }
        
        // Now, construct our final resulting array (from buckets)
        for (index,_) in tempResult.enumerate() {
            if index <= firstNonempty! {
                // set all values to be the same as the first nonempty value
                result[index] = firstValue!
                continue
            } else if let element = tempResult[index] {
                if element.count > 0 {
                    let currentValue = element.value / Double(element.count)
                    result[index] = currentValue
                    continue
                }
            }
            // TODO if either the first two hours are missing then NowCast should not be reported
            result[index] = 0
        }
        
        // TODO we convert array of size 13 to an array of size 12 (see above comment about esdr)
        let modResult = Array( result.dropFirst() )
        
        return modResult
    }
    
    
    func getMostRecent(data: [Int: [Double]], currentTime: Int) -> Double {
        let hourlyValues = constructArrayFromHash(data, currentTime: currentTime)
        return  hourlyValues.first!
    }
    
}
