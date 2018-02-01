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
    
    @IBOutlet weak var labelDirtyDays: UILabel!
    @IBOutlet var labelShowValue: UILabel!
    @IBOutlet var labelReadingMeasurement: UILabel!
    @IBOutlet var labelMeasurementRange: UILabel!
    @IBOutlet var labelValueTitle: UILabel!
    @IBOutlet var labelValueDescription: UILabel!
    @IBOutlet var mainView: UIView!
    var reading: Readable?
    @IBOutlet weak var viewTrackerButton: UIView!
    @IBOutlet weak var labelClosestPm25FeedValue: UILabel!
    @IBOutlet weak var labelClosestPm25FeedName: UILabel!
    @IBOutlet weak var labelClosestOzoneFeedValue: UILabel!
    @IBOutlet weak var labelClosestOzoneFeedName: UILabel!
    @IBOutlet var gestureDailyTracker: UITapGestureRecognizer!
    @IBOutlet weak var viewOzoneAqiButton: UIView!
    @IBOutlet weak var viewPm25AqiButton: UIView!
    @IBOutlet weak var switchMeasurementButton: UIButton!
    
    
    fileprivate func clearAndHide(_ labels: [UILabel?]) {
        for label in labels {
            label?.text = ""
            label?.isHidden = true
        }
    }
    
    
    func feedTrackerResponse(_ text: String) {
        gestureDailyTracker.isEnabled = true
        DispatchQueue.main.async {
            self.labelDirtyDays.text = text
        }
    }
    
    
    func defaultAddressView() {
        labelValueTitle.text = Constants.DefaultReading.DEFAULT_TITLE
        labelValueDescription.text = Constants.DefaultReading.DEFAULT_ADDRESS_DESCRIPTION
        mainView.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
        clearAndHide([labelMeasurementRange, labelShowValue, labelReadingMeasurement])
    }
    
    
    @IBAction func switchMeasurementOnClick(_ sender: Any) {
        NSLog("switchMeasurementOnClick")
        if !(reading is Honeybee) {
            NSLog("unexpected reading in switchMeasurementOnClick (non-Honeybee)")
            return
        }
        // TODO set honeybee particles small/large
        //let honeybee = reading as! Honeybee
    }
    
    
    func defaultDeviceView() {
        labelValueTitle.text = Constants.DefaultReading.DEFAULT_TITLE
        labelValueDescription.text = Constants.DefaultReading.DEFAULT_DEVICE_DESCRIPTION
        mainView.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
        clearAndHide([labelMeasurementRange, labelShowValue, labelReadingMeasurement])
    }
    
    
    func addressView(_ address: SimpleAddress) {
        if address.isCurrentLocation {
            self.navigationItem.rightBarButtonItems = []
        }
        if address.hasReadableValue() {
            var aqi: Int = 0
            
            if address.hasReadableOzoneValue() {
                viewOzoneAqiButton.isHidden = false
                let ozone = address.getReadableOzoneValue()
                if ozone is Ozone_InstantCast {
                    NSLog("instant OZONE=\((ozone as! Ozone_InstantCast).getAqiValue())")
                } else if ozone is Ozone_NowCast {
                    NSLog("nowcast OZONE=\((ozone as! Ozone_NowCast).getAqiValue())")
                }
                let closestFeed = ozone.channel.feed!
                labelClosestOzoneFeedName.text = closestFeed.name
                labelClosestOzoneFeedValue.text = Int(ozone.getAqiValue()).description
                if Int(ozone.getAqiValue()) > aqi {
                    aqi = Int(ozone.getAqiValue())
                }
            }
            if address.hasReadablePm25Value() {
                viewTrackerButton.isHidden = false
                viewPm25AqiButton.isHidden = false
                let pm25 = address.getReadablePm25Value()
                NSLog("PM2.5=\(pm25.getAqiValue())")
                let closestFeed = pm25.channel.feed!
                labelClosestPm25FeedName.text = closestFeed.name
                labelClosestPm25FeedValue.text = Int(pm25.getAqiValue()).description
                if Int(pm25.getAqiValue()) > aqi {
                    aqi = Int(pm25.getAqiValue())
                }
            }
            labelShowValue.text = Int(aqi).description
            let aqiReading = AQIReading(reading: Pm25AqiConverter.aqiToMicrograms(aqi))
            if aqiReading.withinRange() {
                labelMeasurementRange.text = "\(aqiReading.getRangeFromIndex()) AQI"
                labelValueTitle.text = aqiReading.getTitle()
                labelValueDescription.text = aqiReading.getDescription()
                labelReadingMeasurement.text = Constants.Units.RANGE_AQI
                let gradient = CAGradientLayer()
                gradient.frame = mainView.bounds
                let start = aqiReading.getGradientStart()
                let end = aqiReading.getGradientEnd()
                gradient.colors = [
                    start,
                    end
                    ] as [AnyObject]
                mainView.layer.insertSublayer(gradient, at: 0)
                // request tracker
                address.requestDailyFeedTracker(self)
            }
        } else {
            defaultAddressView()
        }
    }
    
    
    func speckView(_ speck: Speck) {
        if speck.hasReadableValue() {
            let micrograms = speck.getReadablePm25Value().getValue()
            labelShowValue.text = Int(micrograms).description
            let speckReading = SpeckReading(reading: micrograms)
            if speckReading.withinRange() {
                labelReadingMeasurement.isHidden = false
                labelMeasurementRange.text = "\(speckReading.getRangeFromIndex()) Micrograms"
                labelValueTitle.text = speckReading.getTitle()
                // TODO descriptions for speck
                //                labelValueDescription.text = Constants.SpeckReading.descriptions[index]
                labelValueDescription.text = speckReading.getDescription()
                mainView.backgroundColor = speckReading.getColor()
                labelReadingMeasurement.text = Constants.Units.RANGE_MICROGRAMS_PER_CUBIC_METER
            } else {
                defaultDeviceView()
            }
        } else {
            defaultDeviceView()
        }
    }
    
    
    func honeybeeView(_ honeybee: Honeybee) {
        NSLog("honeybeeView")
        if honeybee.hasReadableValue() {
            switchMeasurementButton.isHidden = false
            let particles = honeybee.getReadableValues().first!.getValue()
            labelShowValue.text = Int(particles).description
            let honeybeeReading = HoneybeeReading(reading: particles)
            if honeybeeReading.withinRange() {
                labelReadingMeasurement.isHidden = false
                labelMeasurementRange.text = "\(honeybeeReading.getRangeFromIndex()) small particles"
                labelValueTitle.text = honeybeeReading.getTitle()
                labelValueDescription.text = honeybeeReading.getDescription()
                mainView.backgroundColor = honeybeeReading.getColor()
                labelReadingMeasurement.text = Constants.Units.RANGE_PARTICLES_PER_CUBIC_FOOT
            } else {
                defaultDeviceView()
            }
        } else {
            defaultDeviceView()
        }
    }
    
    
    func populateView() {
        gestureDailyTracker.isEnabled = false
        viewOzoneAqiButton.isHidden = true
        viewPm25AqiButton.isHidden = true
        viewTrackerButton.isHidden = true
        switchMeasurementButton.isHidden = true
        navigationItem.title = reading!.getName()
        if (reading! is SimpleAddress) {
            addressView(reading as! SimpleAddress)
        } else if (reading! is Speck) {
            speckView(reading as! Speck)
        } else if (reading! is Honeybee) {
            honeybeeView(reading as! Honeybee)
        } else {
            NSLog("WARNING - could not populate view; unknown readable type")
        }
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func onClickRemove(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
        GlobalHandler.sharedInstance.readingsHandler.removeReading(reading!)
    }
    
    
    // MARK: UIView Overrides
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let airNowReading = self.reading as? AirNowReadable {
            if segue.identifier == "showAirNowSegue" {
                let controller = segue.destination as! AirNowDetailsController
                controller.reading = airNowReading
            } else if segue.identifier == "showAqiExplainSegue" {
                let address = airNowReading as! SimpleAddress
                let controller = segue.destination as! AqiExplanationDetailsController
                controller.reading = address
            } else if segue.identifier == "showTrackerSegue" {
                let address = airNowReading as! SimpleAddress
                let controller = segue.destination as! DailyTrackerController
                controller.address = address
            } else {
                NSLog("ERROR - bad segue name")
            }
        } else {
            NSLog("WARNING - Prepared for a segue but reading was not AirNowReadable")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
