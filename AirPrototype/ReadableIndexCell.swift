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
    
    
    func populate(reading: Readable) {
        if reading.hasReadableValue() {
            var value: String
            let type = reading.getReadableType()
            
            switch type {
            case .ADDRESS:
                textItemLabel.text = Constants.Units.AQI
                let aqi = Converter.microgramsToAqi(reading.getReadableValue())
                value = Int(aqi).description
                let index = Constants.AqiReading.getIndexFromReading(aqi)
                if index >= 0 {
                    self.backgroundColor = Constants.AqiReading.aqiColors[index]
                }
            case .SPECK:
                textItemLabel.text = Constants.Units.MICROGRAMS_PER_CUBIC_METER
                value = (Double(Int(reading.getReadableValue()*10))/10.0).description
                // TODO populate specks
            default:
                NSLog("WARNING - could not determine Readable type for ReadableIndexCell")
                value = reading.getReadableValue().description
            }
            textItemName.text = reading.getName()
            textItemValue.text = value
            textItemLabel.hidden = false
        } else {
            textItemName.text = reading.getName()
            textItemValue.text = Constants.DefaultReading.DEFAULT_LOCATION
            textItemLabel.hidden = true
            self.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
