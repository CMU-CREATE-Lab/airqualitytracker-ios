//
//  Pm25AqiReadableValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol Pm25AqiReadableValue: AqiReadableValue {
    
}


extension Pm25AqiReadableValue {
    
    
    func getAqiValue() -> Double {
        var aqi = 0.0
        // round to tenths
        let micrograms = Double(Int(self.getValue()*10)) / 10.0
        if micrograms < 0 {
            NSLog("ERROR - tried to convert negative Micrograms.")
            aqi = 0.0;
        } else if (micrograms < 12.0) {
            aqi = calculateLinearAqi(50.0,ilo:0.0,chi:12.0,clo:0.0,units:micrograms)
        } else if (micrograms < 35.4) {
            aqi = calculateLinearAqi(100.0,ilo:51.0,chi:35.4,clo:12.1,units:micrograms)
        } else if (micrograms < 55.4) {
            aqi = calculateLinearAqi(150.0,ilo:101.0,chi:55.4,clo:35.5,units:micrograms)
        } else if (micrograms < 150.4) {
            aqi = calculateLinearAqi(200.0,ilo:151.0,chi:150.4,clo:55.5,units:micrograms)
        } else if (micrograms < 250.4) {
            aqi = calculateLinearAqi(300.0,ilo:201.0,chi:250.4,clo:150.5,units:micrograms)
        } else if (micrograms < 350.4) {
            aqi = calculateLinearAqi(400.0,ilo:301.0,chi:350.4,clo:250.5,units:micrograms)
        } else if (micrograms < 500.4) {
            aqi = calculateLinearAqi(500.0,ilo:401.0,chi:500.4,clo:350.5,units:micrograms)
        } else {
            NSLog("ERROR - Micrograms out of range.")
            aqi = 0.0;
        }
        return aqi;
    }
    
}
