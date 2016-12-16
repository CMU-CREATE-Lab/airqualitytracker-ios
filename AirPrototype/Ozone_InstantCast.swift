//
//  Ozone_InstantCast.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class Ozone_InstantCast: AqiReadableValue {
    
    private var value: Double
    private var channel: OzoneChannel
    
    
    init(value: Double, ozoneChannel: OzoneChannel) {
        // check if we are actually using PPB instead of PPM
        if (Constants.ppbOzoneNames.contains(ozoneChannel.name)) {
            self.value = value/1000.0
        } else {
            self.value = value
        }
        self.channel = ozoneChannel
    }
    
    
    func getReadableUnits() -> String { return Constants.Units.PARTS_PER_MILLION }
    func getValue() -> Double { return value }
    
    
    func getAqiValue() -> Double {
        var aqi = 0.0
        // EPA caluclation rounds to a whole PPB (and we have PPM)
        let ppm = Double(Int(self.getValue()*1000)) / 1000.0
        if ppm < 0 {
            NSLog("ERROR - tried to convert negative PPM.")
            aqi = 0.0;
        } else if (ppm < 0.124) {
            NSLog("InstantCast AQI for Ozone is not in 1-hr threshold; setting aqi to 0.")
            aqi = 0.0;
        } else if (ppm < 0.164) {
            aqi = calculateLinearAqi(150.0,ilo:101.0,chi:0.164,clo:0.125,units:ppm)
        } else if (ppm < 0.204) {
            aqi = calculateLinearAqi(200.0,ilo:151.0,chi:0.204,clo:0.165,units:ppm)
        } else if (ppm < 0.404) {
            aqi = calculateLinearAqi(300.0,ilo:201.0,chi:0.404,clo:0.205,units:ppm)
        } else if (ppm < 0.504) {
            aqi = calculateLinearAqi(400.0,ilo:301.0,chi:0.504,clo:0.405,units:ppm)
        } else if (ppm < 0.604) {
            aqi = calculateLinearAqi(500.0,ilo:401.0,chi:0.604,clo:0.505,units:ppm)
        } else {
            NSLog("ERROR - PPM out of range.")
            aqi = 0.0;
        }
        return aqi;
    }
    
}
