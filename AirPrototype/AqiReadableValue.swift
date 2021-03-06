//
//  AqiReadableValue.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

protocol AqiReadableValue: ReadableValue {
    
    // convert stored class value into AQI
    func getAqiValue() -> Double
    
}


func calculateLinearAqi(_ ihi: Double,ilo: Double,chi: Double,clo: Double,units: Double) -> Double {
    return (ihi-ilo) / (chi-clo) * (units-clo) + ilo
}
