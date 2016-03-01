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
    
    
    func populate(reading: Readable) {
        textCurrentLocation.hidden = true
        if reading.hasReadableValue() {
            var value: String
            var index: Int
            let type = reading.getReadableType()
            textItemName.text = reading.getName()
            
            switch type {
            case .ADDRESS:
                textItemLabel.text = Constants.Units.AQI
                let aqi = AqiConverter.microgramsToAqi(reading.getReadableValue())
                value = Int(aqi).description
                index = Constants.AqiReading.getIndexFromReading(aqi)
                if index >= 0 {
                    self.backgroundColor = Constants.AqiReading.aqiColors[index]
                }
                // current location
                let address = reading as! SimpleAddress
                if address.isCurrentLocation && address.hasReadableValue() {
                    textCurrentLocation.hidden = false
                }
            case .SPECK:
                textItemLabel.text = Constants.Units.MICROGRAMS_PER_CUBIC_METER
                let micrograms = reading.getReadableValue()
                value = Int(micrograms).description
                index = Constants.SpeckReading.getIndexFromReading(micrograms)
                if index >= 0 {
                    self.backgroundColor = Constants.SpeckReading.normalColors[index]
                }
            default:
                NSLog("WARNING - could not determine Readable type for ReadableIndexCell")
                value = reading.getReadableValue().description
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
