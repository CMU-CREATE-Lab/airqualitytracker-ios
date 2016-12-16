//
//  Ozone_NowCast.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/15/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class Ozone_NowCast: AqiReadableValue {
    
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
        } else if (ppm < 0.054) {
            aqi = calculateLinearAqi(50.0,ilo:0.0,chi:0.054,clo:0.0,units:ppm)
        } else if (ppm < 0.070) {
            aqi = calculateLinearAqi(100.0,ilo:51.0,chi:0.070,clo:0.055,units:ppm)
        } else if (ppm < 0.085) {
            aqi = calculateLinearAqi(150.0,ilo:101.0,chi:0.085,clo:0.071,units:ppm)
        } else if (ppm < 0.105) {
            aqi = calculateLinearAqi(200.0,ilo:151.0,chi:0.105,clo:0.086,units:ppm)
        } else if (ppm < 0.200) {
            aqi = calculateLinearAqi(300.0,ilo:201.0,chi:0.200,clo:0.106,units:ppm)
        } else {
            NSLog("ERROR - PPM out of range.")
            aqi = 0.0;
        }
        return aqi;
    }
    
}
