//
//  ReadableIndexCell.swift
//  AirPrototype
//
//  Created by mtasota on 9/9/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ReadableIndexCell: UICollectionViewCell {
    
    @IBOutlet var textItemValue: UILabel!
    @IBOutlet var textItemLabel: UILabel!
    @IBOutlet var textItemName: UILabel!
    @IBOutlet var textCurrentLocation: UILabel!
    @IBOutlet weak var textTemperature: UILabel!
    @IBOutlet weak var textHumidity: UILabel!
    
    
    func populate(reading: Readable) {
        textCurrentLocation.hidden = true
        textTemperature.hidden = true
        textHumidity.hidden = true
        
        if reading.hasReadableValue() {
            var value: String
            textItemName.text = reading.getName()
            
            if (reading.hasReadableValue()) {
                if (reading is SimpleAddress) {
                    textItemLabel.text = Constants.Units.AQI
                    let micrograms = (reading as! SimpleAddress).getReadableValues().first!.getValue()
                    let aqi = Pm25AqiConverter.microgramsToAqi(micrograms)
                    value = Int(aqi).description
                    let aqiReading = AQIReading(reading: micrograms)
                    if aqiReading.withinRange() {
                        self.backgroundColor = aqiReading.getColor()
                    }
                    // current location
                    let address = reading as! SimpleAddress
                    if address.isCurrentLocation {
                        textCurrentLocation.hidden = false
                    }
                } else if (reading is Speck) {
                    textItemLabel.text = Constants.Units.MICROGRAMS_PER_CUBIC_METER
                    let speck = reading as! Speck
                    let micrograms = speck.getReadablePm25Value().getValue()
                    value = Int(micrograms).description
                    let speckReading = SpeckReading(reading: micrograms)
                    if speckReading.withinRange() {
                        self.backgroundColor = speckReading.getColor()
                    }
                    if speck.hasReadableTemperatureValue() {
                        textTemperature.text = "\(speck.getReadableTemperatureValue().getValue()) \(speck.getReadableTemperatureValue().getReadableUnits())"
                        textTemperature.hidden = false
                    }
                    if speck.hasReadableHumidityValue() {
                        textHumidity.text = "💧\(speck.getReadableHumidityValue().getValue()) \(speck.getReadableHumidityValue().getReadableUnits())"
                        textHumidity.hidden = false
                    }
                } else {
                    NSLog("WARNING - could not determine Readable type for ReadableIndexCell")
                    value = ""
                }
            } else {
                NSLog("WARNING - Readable does not have readable value")
                value = ""
            }
            
            textItemValue.text = value
            textItemLabel.hidden = false
        } else {
            textItemName.text = reading.getName()
            textItemValue.text = Constants.DefaultReading.DEFAULT_LOCATION
            textItemLabel.hidden = true
            self.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
            if let address = reading as? SimpleAddress {
                if address.isCurrentLocation && address.hasReadableValue() {
                    textCurrentLocation.hidden = false
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textCurrentLocation.hidden = true
    }
    
}
