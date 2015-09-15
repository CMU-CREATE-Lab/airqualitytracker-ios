//
//  AddressShowController.swift
//  AirPrototype
//
//  Created by mtasota on 7/20/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AddressShowController: UIViewController {
    
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelShowValue: UILabel!
    @IBOutlet var labelReadingMeasurement: UILabel!
    @IBOutlet var labelMeasurementRange: UILabel!
    @IBOutlet var labelValueTitle: UILabel!
    @IBOutlet var labelValueDescription: UILabel!
    @IBOutlet var mainView: UIView!
    var address: SimpleAddress?
    
    func defaultView() {
        labelMeasurementRange.text = ""
        labelValueTitle.text = Constants.DefaultReading.DEFAULT_TITLE
        labelValueDescription.text = Constants.DefaultReading.DEFAULT_DESCRIPTION
        mainView.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
        labelShowValue.text = ""
        labelReadingMeasurement.text = ""
        labelReadingMeasurement.hidden = true
    }
    
    func addressView() {
        if address!.hasReadableValue() {
            let aqi = Converter.microgramsToAqi(address!.getReadableValue())
            labelShowValue.text = Int(aqi).description
            let index = Constants.AqiReading.getIndexFromReading(aqi)
            if index < 0 {
                defaultView()
            } else {
                labelReadingMeasurement.hidden = false
                labelMeasurementRange.text = "\(Constants.AqiReading.getRangeFromIndex(index)) AQI"
                labelValueTitle.text = Constants.AqiReading.titles[index]
                labelValueDescription.text = Constants.AqiReading.descriptions[index]
                labelReadingMeasurement.text = Constants.Units.RANGE_AQI
                var gradient = CAGradientLayer()
                gradient.frame = mainView.bounds
                let start = Constants.AqiReading.aqiGradientColorStart[index]
                let end = Constants.AqiReading.aqiGradientColorEnd[index]
                gradient.colors = [
                    start,
                    end
                    ] as [AnyObject]
                mainView.layer.insertSublayer(gradient, atIndex: 0)
            }
        } else {
            defaultView()
        }
    }
    
    func speckView() {
        // TODO speck view actions
//        labelReadingMeasurement.hidden = false
    }
    
    func populateView() {
        labelName.text = address!.name
        let type = address!.getReadableType()
        switch type {
        case .ADDRESS:
            addressView()
        case .SPECK:
            speckView()
        default:
            NSLog("WARNING - could not populate view; unknown readable type")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Loaded AddressShow with address " + address!.name)
        populateView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}