//
//  AirNowDetailsTableCell.swift
//  AirPrototype
//
//  Created by mtasota on 3/2/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AirNowDetailsTableCell: UITableViewCell {
    

    @IBOutlet var labelParamName: UILabel!
    @IBOutlet var viewColored: UIView!
    @IBOutlet var labelAqi: UILabel!
    
    func populate(observation: AirNowObservation) {
        // TODO populate actions
        let aqi = observation.aqi
        labelAqi.text = "\(aqi.description) AQI"
        labelParamName.text = observation.parameterName
        let index = Constants.AqiReading.getIndexFromReading(aqi)
        viewColored.backgroundColor = Constants.AqiReading.aqiColors[index]
    }
    
}