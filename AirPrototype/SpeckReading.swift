//
//  SpeckReading.swift
//  AirPrototype
//
//  Created by Mike Tasota on 6/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SpeckReading: Scalable {
    
    // static class attributes
    private static let descriptions = [
        "Air quality is considered satisfactory, and air pollution poses little or no risk.",
        "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people. For example, people who are unusually sensitive to ozone may experience respiratory symptoms.",
        "Although general public is not likely to be affected at this AQI range, people with lung disease, older adults and children are at a greater risk from exposure to ozone, whereas persons with heart and lung disease, older adults and children are at greater risk from the presence of particles in the air.",
        "Everyone may begin to experience some adverse health effects, and members of the sensitive groups may experience more serious effects.",
        "This would trigger a health alert signifying that everyone may experience more serious health effects.",
        "This would trigger a health warning of emergency conditions. The entire population is more likely to be affected."
    ]
    private static let normalColors = [
        UIColor(red: 26.0/255.0, green: 152.0/255.0, blue: 80.0/255.0, alpha: 1.0),
        UIColor(red: 145.0/255.0, green: 207.0/255.0, blue: 96.0/255.0, alpha: 1.0),
        UIColor(red: 217.0/255.0, green: 239.0/255.0, blue: 139.0/255.0, alpha: 1.0),
        UIColor(red: 254.0/255.0, green: 224.0/255.0, blue: 139.0/255.0, alpha: 1.0),
        UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 89.0/255.0, alpha: 1.0),
        UIColor(red: 215.0/255.0, green: 48.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    ]
    private static let colorblindColors = [
        "#4575b4", "#91bfdb", "#e0f3f8",
        "#fee090", "#fc8d59", "#d73027"
    ]
    private static let titles = [
        "Good", "Moderate", "Slightly Elevated",
        "Elevated", "High", "Very High"
    ]
    // ranges measured in ug/m^3
    private static let ranges: [Double] = [
        21, 41, 81,
        161, 321
    ]
    // class attributes
    private var reading: Double
    private var index: Int
    // getters
    func getColor() -> UIColor { return SpeckReading.normalColors[self.index] }
    func getTitle() -> String { return SpeckReading.titles[self.index] }
    func getDescription() -> String { return SpeckReading.descriptions[self.index] }
    
    
    init(reading: Double) {
        self.reading = reading
        self.index = SpeckReading.getIndexFromReading(self.reading)
    }
    
    
    func withinRange() -> Bool {
        return (index >= 0)
    }
    
    
    static func getIndexFromReading(reading: Double) -> Int {
        if reading < 0 {
            return -1
        }
        var index: Int
        for index = 0; index < SpeckReading.ranges.count; index+=1 {
            if reading < SpeckReading.ranges[index] {
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
            return "0-\(SpeckReading.ranges[0])"
        } else if index == 5 {
            return "\(SpeckReading.ranges[4])+"
        } else {
            return "\(SpeckReading.ranges[index-1])-\(SpeckReading.ranges[index])"
        }
    }
}