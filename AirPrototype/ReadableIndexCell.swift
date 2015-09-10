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
        var value: String
        let type = reading.getReadableType()
        
        switch type {
        case .ADDRESS:
            // actions
            textItemLabel.text = "AQI"
            let aqi = Converter.microgramsToAqi(reading.getReadableValue())
            value = Int(aqi).description
        case .SPECK:
            // TODO pretty
            textItemLabel.text = "ug/m3"
            value = (Double(Int(reading.getReadableValue()*10))/10.0).description
        default:
            NSLog("could not determine Readable type")
            value = reading.getReadableValue().description
//            self.backgroundColor = UIColor.blackColor()
        }
        textItemName.text = reading.getName()
        textItemValue.text = value
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
