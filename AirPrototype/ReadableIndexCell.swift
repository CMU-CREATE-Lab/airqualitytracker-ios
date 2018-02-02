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
    
    
    func populate(_ reading: Readable) {
        textCurrentLocation.isHidden = true
        textTemperature.isHidden = true
        textHumidity.isHidden = true
        
        if reading.hasReadableValue() {
            var value: String
            textItemName.text = reading.getName()
            
            if (reading.hasReadableValue()) {
                if (reading is SimpleAddress) {
                    textItemLabel.text = Constants.Units.AQI
                    var aqi: Int = 0
                    let address = reading as! SimpleAddress
                    if address.hasReadablePm25Value() && Int(address.getReadablePm25Value().getAqiValue()) > aqi {
                        aqi = Int(address.getReadablePm25Value().getAqiValue())
                    }
                    if address.hasReadableOzoneValue() && Int(address.getReadableOzoneValue().getAqiValue()) > aqi {
                        aqi = Int(address.getReadableOzoneValue().getAqiValue())
                    }
                    value = Int(aqi).description
                    let aqiReading = AQIReading(reading: Pm25AqiConverter.aqiToMicrograms(Int(aqi)))
                    if aqiReading.withinRange() {
                        self.backgroundColor = aqiReading.getColor()
                    }
                    // current location
                    if address.isCurrentLocation {
                        textCurrentLocation.isHidden = false
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
                        textTemperature.isHidden = false
                    }
                    if speck.hasReadableHumidityValue() {
                        textHumidity.text = "💧\(speck.getReadableHumidityValue().getValue()) \(speck.getReadableHumidityValue().getReadableUnits())"
                        textHumidity.isHidden = false
                    }
                } else if (reading is Honeybee) {
                    let honeybee = reading as! Honeybee
                    textItemLabel.text = honeybee.measureSmall ? "small" : "large"
                    let smallParticles = honeybee.getReadableValues().first!.getValue()
                    value = Int(smallParticles).description
                    let honeybeeReading = HoneybeeReading(reading: smallParticles)
                    if honeybeeReading.withinRange() {
                        self.backgroundColor = honeybeeReading.getColor()
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
            textItemLabel.isHidden = false
        } else {
            textItemName.text = reading.getName()
            textItemValue.text = Constants.DefaultReading.DEFAULT_LOCATION
            textItemLabel.isHidden = true
            self.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
            if let address = reading as? SimpleAddress {
                if address.isCurrentLocation && address.hasReadableValue() {
                    textCurrentLocation.isHidden = false
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textCurrentLocation.isHidden = true
    }
    
}
