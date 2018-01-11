//
//  HoneybeeReading.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 1/10/18.
//  Copyright © 2018 CMU Create Lab. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class HoneybeeReading: Scalable {
    
    // static class attributes
    fileprivate static let descriptions = [
        "TODO description",
        "TODO description",
        "TODO description",
        "TODO description",
        "TODO description",
        "TODO description"
    ]
    // TODO change colors (uses Speck colors for now)
    fileprivate static let normalColors = [
        UIColor(red: 26.0/255.0, green: 152.0/255.0, blue: 80.0/255.0, alpha: 1.0),
        UIColor(red: 145.0/255.0, green: 207.0/255.0, blue: 96.0/255.0, alpha: 1.0),
        UIColor(red: 217.0/255.0, green: 239.0/255.0, blue: 139.0/255.0, alpha: 1.0),
        UIColor(red: 254.0/255.0, green: 224.0/255.0, blue: 139.0/255.0, alpha: 1.0),
        UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 89.0/255.0, alpha: 1.0),
        UIColor(red: 215.0/255.0, green: 48.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    ]
    fileprivate static let titles = [
        "Excellent", "Very Good", "Good",
        "Fair", "Poor", "Very Poor"
    ]
    // ranges measured in ug/m^3
    fileprivate static let ranges: [Double] = [
        75, 150, 300,
        1050, 3000
    ]
    // class attributes
    fileprivate var reading: Double
    fileprivate var index: Int
    // getters
    func getColor() -> UIColor { return HoneybeeReading.normalColors[self.index] }
    func getTitle() -> String { return HoneybeeReading.titles[self.index] }
    func getDescription() -> String { return HoneybeeReading.descriptions[self.index] }
    
    
    init(reading: Double) {
        self.reading = reading
        self.index = HoneybeeReading.getIndexFromReading(self.reading)
    }
    
    
    func withinRange() -> Bool {
        return (index >= 0)
    }
    
    
    static func getIndexFromReading(_ reading: Double) -> Int {
        if reading < 0 {
            return -1
        }
        var index: Int
        for index in 0..<HoneybeeReading.ranges.count {
            if reading < HoneybeeReading.ranges[index] {
                return index
            }
        }
        return ranges.count
    }
    
    func getRangeFromIndex() -> String {
        if (index < 0) {
            NSLog("getRangeFromIndex received index < 0.")
            return ""
        } else if index == 0 {
            return "0-\(HoneybeeReading.ranges[0])"
        } else if index == HoneybeeReading.ranges.count {
            return "\(HoneybeeReading.ranges[HoneybeeReading.ranges.count-1])+"
        } else {
            return "\(HoneybeeReading.ranges[index-1])-\(HoneybeeReading.ranges[index])"
        }
    }
}
