//
//  Converter.swift
//  AirPrototype
//
//  Created by mtasota on 7/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Pm25AqiConverter {
    
    
    private static func calculateLinearAqi(micrograms: Double, ihi: Double, ilo: Double, chi: Double, clo: Double) -> Double {
        return (ihi-ilo) / (chi-clo) * (micrograms-clo) + ilo
    }
    
    
    private static func calculateLinearMicrograms(aqi: Double, ihi: Double, ilo: Double, chi: Double, clo: Double) -> Double {
        return (aqi-ilo) * (chi-clo) / (ihi-ilo) + clo
    }
    
    
    static func decimalPrecision(number: Double, digits: Int) -> Double {
        if digits < 0 {
            return number
        }
        let coefficient = pow(10.0, Double(digits))
        return Double(Int(number*coefficient))/coefficient
    }
    
    
    static func microgramsToAqi(inputMicrograms: Double) -> Double {
        var aqi = 0.0
        // round to tenths
        let micrograms = Double(Int(inputMicrograms*10)) / 10.0
        if micrograms < 0 {
            NSLog("ERROR - tried to convert negative Micrograms.")
            aqi = 0.0;
        } else if (micrograms < 12.0) {
            aqi = calculateLinearAqi(micrograms,ihi:50.0,ilo:0.0,chi:12.0,clo:0.0)
        } else if (micrograms < 35.4) {
            aqi = calculateLinearAqi(micrograms,ihi:100.0,ilo:50.0,chi:35.4,clo:12.1)
        } else if (micrograms < 55.4) {
            aqi = calculateLinearAqi(micrograms,ihi:150.0,ilo:101.0,chi:55.4,clo:35.5)
        } else if (micrograms < 150.4) {
            aqi = calculateLinearAqi(micrograms,ihi:200.0,ilo:151.0,chi:150.4,clo:55.5)
        } else if (micrograms < 250.4) {
            aqi = calculateLinearAqi(micrograms,ihi:300.0,ilo:201.0,chi:250.4,clo:150.5)
        } else if (micrograms < 350.4) {
            aqi = calculateLinearAqi(micrograms,ihi:400.0,ilo:301.0,chi:350.4,clo:250.5)
        } else if (micrograms < 500.4) {
            aqi = calculateLinearAqi(micrograms,ihi:500.0,ilo:401.0,chi:500.4,clo:350.5)
        } else {
            NSLog("ERROR - Micrograms out of range.")
            aqi = 0.0;
        }
        return aqi;
    }
    
    
    static func aqiToMicrograms(inputAqi: Double) -> Double {
        var micrograms = 0.0;
        // round to tenths
        let aqi = Double(Int(inputAqi*10))/10.0;
        if (aqi < 0) {
            NSLog("ERROR - tried to convert negative AQI.");
            micrograms = 0.0;
        } else if (aqi < 50.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:50.0,ilo:0.0,chi:12.0,clo:0.0)
        } else if (aqi < 100.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:100.0,ilo:50.0,chi:35.4,clo:12.1)
        } else if (aqi < 150.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:150.0,ilo:101.0,chi:55.4,clo:35.5)
        } else if (aqi < 200.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:200.0,ilo:151.0,chi:150.4,clo:55.5)
        } else if (aqi < 300.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:300.0,ilo:201.0,chi:250.4,clo:150.5)
        } else if (aqi < 400.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:400.0,ilo:301.0,chi:350.4,clo:250.5)
        } else if (aqi < 500.0) {
            micrograms = calculateLinearMicrograms(aqi,ihi:500.0,ilo:401.0,chi:500.4,clo:350.5)
        } else {
            NSLog("ERROR - AQI out of range.");
            micrograms = 0.0;
        }
        return micrograms;
    }
    
}
