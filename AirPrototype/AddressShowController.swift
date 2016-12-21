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
    var closestFeed: Pm25Feed?
    var reading: Readable?
    @IBOutlet var viewAqiButton: UIView!
    @IBOutlet weak var viewTrackerButton: UIView!
    @IBOutlet var labelClosestFeedName: UILabel!
    @IBOutlet var gestureDailyTracker: UITapGestureRecognizer!
    
    
    private func clearAndHide(labels: [UILabel!]) {
        for label in labels {
            label.text = ""
            label.hidden = true
        }
    }
    
    
    func feedTrackerResponse(text: String) {
        gestureDailyTracker.enabled = true
        dispatch_async(dispatch_get_main_queue()) {
            self.labelDirtyDays.text = text
        }
    }
    
    
    func defaultView() {
        labelValueTitle.text = Constants.DefaultReading.DEFAULT_TITLE
        labelValueDescription.text = Constants.DefaultReading.DEFAULT_DESCRIPTION
        mainView.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
        clearAndHide([labelMeasurementRange, labelShowValue, labelReadingMeasurement])
        viewAqiButton.hidden = true
        viewTrackerButton.hidden = true
    }
    
    
    func addressView(address: SimpleAddress) {
        if address.isCurrentLocation {
            self.navigationItem.rightBarButtonItems = []
        }
        if address.hasReadableValue() {
            let micrograms = address.getReadablePm25Value().getValue()
            let aqi = Pm25AqiConverter.microgramsToAqi(micrograms)
            NSLog("PM2.5=\(aqi)")
            if address.hasReadableOzoneValue() {
                let ozone = address.getReadableOzoneValue()
                if ozone is Ozone_InstantCast {
                    NSLog("instant OZONE=\((ozone as! Ozone_InstantCast).getAqiValue())")
                } else if ozone is Ozone_NowCast {
                    NSLog("nowcast OZONE=\((ozone as! Ozone_NowCast).getAqiValue())")
                }
            }
            labelShowValue.text = Int(aqi).description
            let aqiReading = AQIReading(reading: micrograms)
            if aqiReading.withinRange() {
                // get feed name
                closestFeed = address.getReadablePm25Value().channel.feed
                labelClosestFeedName.text = closestFeed?.getName()
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
                mainView.layer.insertSublayer(gradient, atIndex: 0)
                // request tracker
                address.requestDailyFeedTracker(self)
            } else {
                defaultView()
            }
        } else {
            defaultView()
        }
    }
    
    
    func speckView(speck: Speck) {
        viewAqiButton.hidden = true
        viewTrackerButton.hidden = true
        if speck.hasReadableValue() {
            let micrograms = speck.getReadablePm25Value().getValue()
            labelShowValue.text = Int(micrograms).description
            let speckReading = SpeckReading(reading: micrograms)
            if speckReading.withinRange() {
                labelReadingMeasurement.hidden = false
                labelMeasurementRange.text = "\(speckReading.getRangeFromIndex()) Micrograms"
                labelValueTitle.text = speckReading.getTitle()
                // TODO descriptions for speck
                //                labelValueDescription.text = Constants.SpeckReading.descriptions[index]
                labelValueDescription.text = speckReading.getDescription()
                mainView.backgroundColor = speckReading.getColor()
                labelReadingMeasurement.text = Constants.Units.RANGE_MICROGRAMS_PER_CUBIC_METER
            } else {
                defaultView()
            }
        } else {
            defaultView()
        }
    }
    
    
    func populateView() {
        gestureDailyTracker.enabled = false
        navigationItem.title = reading!.getName()
        if (reading! is SimpleAddress) {
            addressView(reading as! SimpleAddress)
        } else if (reading! is Speck) {
            speckView(reading as! Speck)
        } else {
            NSLog("WARNING - could not populate view; unknown readable type")
        }
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func onClickRemove(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        GlobalHandler.sharedInstance.readingsHandler.removeReading(reading!)
    }
    
    
    // MARK: UIView Overrides
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let airNowReading = self.reading as? AirNowReadable {
            if segue.identifier == "showAirNowSegue" {
                let controller = segue.destinationViewController as! AirNowDetailsController
                controller.reading = airNowReading
            } else if segue.identifier == "showAqiExplainSegue" {
                let address = airNowReading as! SimpleAddress
                let controller = segue.destinationViewController as! AqiExplanationDetailsController
                controller.reading = address
                controller.feed = address.closestFeed
            } else if segue.identifier == "showTrackerSegue" {
                let address = airNowReading as! SimpleAddress
                let controller = segue.destinationViewController as! DailyTrackerController
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
