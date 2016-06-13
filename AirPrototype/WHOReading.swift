//
//  WHOReading.swift
//  AirPrototype
//
//  Created by Mike Tasota on 6/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class WHOReading: Scalable {
    
    // static class attributes
    private static let colors = [
        UIColor(red: 163.0/255.0, green: 186.0/255.0, blue: 92.0/255.0, alpha: 1.0),
        UIColor(red: 233.0/255.0, green: 182.0/255.0, blue: 66.0/255.0, alpha: 1.0),
        UIColor(red: 233.0/255.0, green: 140.0/255.0, blue: 55.0/255.0, alpha: 1.0),
        UIColor(red: 226.0/255.0, green: 79.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    ]
    private static let titles = [
        "Good", "Moderate", "Elevated", "High"
    ]
    // ranges measured in ug/m^3
    private static let ranges = [
        10.1, 25.5, 50.5
    ]
    // class attributes
    private var reading: Double
    private var index: Int
    // getters
    func getColor() -> UIColor { return WHOReading.colors[self.index] }
    func getTitle() -> String { return WHOReading.titles[self.index] }
    
    
    init(reading: Double) {
        self.reading = reading
        self.index = SpeckReading.getIndexFromReading(self.reading)
    }
    
    
    func withinRange() -> Bool {
        return (index >= 0)
    }
    
    
    static func getIndexFromReading(reading: Double) -> Int {
        if reading < 0 {
            return -1;
        }
        var index: Int
        for index = 0; index < ranges.count; index+=1 {
            if reading < ranges[index] {
                return index
            }
        }
        return -1
    }
    
    
    func getRangeFromIndex() -> String {
        if (index < 0) {
            NSLog("getRangeFromIndex received index < 0.")
            return ""
        } else if index == 0 {
            return "0-\(WHOReading.ranges[0])"
        } else if index == 3 {
            return "\(WHOReading.ranges[4])+"
        } else {
            return "\(WHOReading.ranges[index-1])-\(WHOReading.ranges[index])"
        }
    }
    
}