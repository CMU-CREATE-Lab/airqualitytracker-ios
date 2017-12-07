//
//  AQIReading.swift
//  AirPrototype
//
//  Created by Mike Tasota on 6/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AQIReading: Scalable {
    
    // static class attributes
    fileprivate static let descriptions = [
        "Air quality is considered satisfactory, and air pollution poses little or no risk.",
        "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people. For example, people who are unusually sensitive to ozone may experience respiratory symptoms.",
        "Although general public is not likely to be affected at this AQI range, people with lung disease, older adults and children are at a greater risk from exposure to ozone, whereas persons with heart and lung disease, older adults and children are at greater risk from the presence of particles in the air.",
        "Everyone may begin to experience some adverse health effects, and members of the sensitive groups may experience more serious effects.",
        "This would trigger a health alert signifying that everyone may experience more serious health effects.",
        "This would trigger a health warning of emergency conditions. The entire population is more likely to be affected."
    ]
    fileprivate static let titles = [
        "Good", "Moderate", "Unhealthy for Sensitive Groups",
        "Unhealthy", "Very Unhealthy", "Hazardous"
    ]
    fileprivate static let aqiColors = [
        UIColor(red: 163.0/255.0, green: 186.0/255.0, blue: 92.0/255.0, alpha: 1.0),
        UIColor(red: 233.0/255.0, green: 182.0/255.0, blue: 66.0/255.0, alpha: 1.0),
        UIColor(red: 233.0/255.0, green: 140.0/255.0, blue: 55.0/255.0, alpha: 1.0),
        UIColor(red: 226.0/255.0, green: 79.0/255.0, blue: 54.0/255.0, alpha: 1.0),
        UIColor(red: 181.0/255.0, green: 67.0/255.0, blue: 130.0/255.0, alpha: 1.0),
        UIColor(red: 178.0/255.0, green: 38.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    ]
    fileprivate static let aqiColorsHexStrings = [
        "a3ba5c", "e9b642", "e98c37",
        "e24f36", "b54382", "b22651"
    ]
    fileprivate static let aqiFontColors = [
        UIColor(red: 25.0/255.0, green: 32.0/255.0, blue: 21.0/255.0, alpha: 1.0),
        UIColor(red: 42.0/255.0, green: 30.0/255.0, blue: 17.0/255.0, alpha: 1.0),
        UIColor(red: 38.0/255.0, green: 23.0/255.0, blue: 5.0/255.0, alpha: 1.0),
        UIColor(red: 51.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0),
        UIColor(red: 45.0/255.0, green: 13.0/255.0, blue: 24.0/255.0, alpha: 1.0),
        UIColor(red: 40.0/255.0, green: 6.0/255.0, blue: 11.0/255.0, alpha: 1.0)
    ]
    fileprivate static let aqiGradientColorStart = [
        UIColor(red: 163.0/255.0, green: 186.0/255.0, blue: 92.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 233.0/255.0, green: 182.0/255.0, blue: 66.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 233.0/255.0, green: 140.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 226.0/255.0, green: 79.0/255.0, blue: 54.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 181.0/255.0, green: 67.0/255.0, blue: 130.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 178.0/255.0, green: 38.0/255.0, blue: 81.0/255.0, alpha: 1.0).cgColor
    ]
    fileprivate static let aqiGradientColorEnd = [
        UIColor(red: 122.0/255.0, green: 144.0/255.0, blue: 85.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 193.0/255.0, green: 143.0/255.0, blue: 53.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 180.0/255.0, green: 76.0/255.0, blue: 38.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 173.0/255.0, green: 34.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 153.0/255.0, green: 42.0/255.0, blue: 104.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 140.0/255.0, green: 23.0/255.0, blue: 57.0/255.0, alpha: 1.0).cgColor
    ]
    fileprivate static let ranges: [Double] = [
        50, 100, 150,
        200, 300
    ]
    // class attributes
    fileprivate var reading: Double
    fileprivate var index: Int
    // getters
    func getColor() -> UIColor { return AQIReading.aqiColors[self.index] }
    func getAqiHexString() -> String { return AQIReading.aqiColorsHexStrings[self.index] }
    func getFontColor() -> UIColor { return AQIReading.aqiFontColors[self.index] }
    func getTitle() -> String { return AQIReading.titles[self.index] }
    func getDescription() -> String { return AQIReading.descriptions[self.index] }
    func getGradientStart() -> CGColor { return AQIReading.aqiGradientColorStart[self.index] }
    func getGradientEnd() -> CGColor { return AQIReading.aqiGradientColorEnd[self.index] }
    
    
    init(reading: Double) {
        self.reading = reading
        self.index = AQIReading.getIndexFromReading(Pm25AqiConverter.microgramsToAqi(self.reading))
    }
    
    
    func withinRange() -> Bool {
        return (index >= 0)
    }
    
    
    static func getIndexFromReading(_ reading: Double) -> Int {
        if reading < 0 {
            return -1;
        }
        var index: Int
        for index in 0..<ranges.count {
            if reading < ranges[index] {
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
            return "0-\(AQIReading.ranges[0])"
        } else if index == AQIReading.ranges.count {
            return "\(AQIReading.ranges[AQIReading.ranges.count-1])+"
        } else {
            return "\(AQIReading.ranges[index-1])-\(AQIReading.ranges[index])"
        }
    }
    
}
