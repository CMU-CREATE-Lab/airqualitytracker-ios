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
    
//    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelShowValue: UILabel!
    @IBOutlet var labelReadingMeasurement: UILabel!
    @IBOutlet var labelMeasurementRange: UILabel!
    @IBOutlet var labelValueTitle: UILabel!
    @IBOutlet var labelValueDescription: UILabel!
//    @IBOutlet var labelReadingFromFeed: UILabel!
//    @IBOutlet var labelClosestFeedName: UILabel!
    @IBOutlet var mainView: UIView!
    var closestFeed: Feed?
    var reading: Readable?
    
    @IBOutlet var buttonAqiExplanation: UIButton!
    @IBOutlet var buttonAirNow: UIButton!
    @IBOutlet var viewAqiButton: UIView!
    
    private func clearAndHide(labels: [UILabel!]) {
        for label in labels {
            label.text = ""
            label.hidden = true
        }
    }
    
    
    func defaultView() {
        labelValueTitle.text = Constants.DefaultReading.DEFAULT_TITLE
        labelValueDescription.text = Constants.DefaultReading.DEFAULT_DESCRIPTION
        mainView.backgroundColor = Constants.DefaultReading.DEFAULT_COLOR_BACKGROUND
//        clearAndHide([labelMeasurementRange, labelShowValue, labelReadingMeasurement, labelReadingFromFeed, labelClosestFeedName])
        clearAndHide([labelMeasurementRange, labelShowValue, labelReadingMeasurement])
        buttonAqiExplanation.hidden = true
        buttonAirNow.hidden = true
        viewAqiButton.hidden = true
    }
    
    
    func addressView(address: SimpleAddress) {
        if address.isCurrentLocation {
            self.navigationItem.rightBarButtonItems = []
        }
        if address.hasReadableValue() {
            let aqi = AqiConverter.microgramsToAqi(address.getReadableValue())
            labelShowValue.text = Int(aqi).description
            let index = Constants.AqiReading.getIndexFromReading(aqi)
            if index < 0 {
                defaultView()
            } else {
                // get feed name
                closestFeed = address.closestFeed
//                labelClosestFeedName.text = closestFeed?.getName()
                labelMeasurementRange.text = "\(Constants.AqiReading.getRangeFromIndex(index)) AQI"
                labelValueTitle.text = Constants.AqiReading.titles[index]
                labelValueDescription.text = Constants.AqiReading.descriptions[index]
                labelReadingMeasurement.text = Constants.Units.RANGE_AQI
                let gradient = CAGradientLayer()
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
    
    
    func speckView(speck: Speck) {
//        clearAndHide([labelReadingFromFeed, labelClosestFeedName])
        buttonAqiExplanation.hidden = true
        buttonAirNow.hidden = true
        viewAqiButton.hidden = true
        if speck.hasReadableValue() {
            let micrograms = speck.getReadableValue()
            labelShowValue.text = Int(micrograms).description
            let index = Constants.SpeckReading.getIndexFromReading(micrograms)
            if index < 0{
                defaultView()
            } else {
                labelReadingMeasurement.hidden = false
                labelMeasurementRange.text = "\(Constants.SpeckReading.getRangeFromIndex(index)) Micrograms"
                labelValueTitle.text = Constants.SpeckReading.titles[index]
                // TODO descriptions for speck
//                labelValueDescription.text = Constants.SpeckReading.descriptions[index]
                labelValueDescription.text = Constants.AqiReading.descriptions[index]
                mainView.backgroundColor = Constants.SpeckReading.normalColors[index]
                labelReadingMeasurement.text = Constants.Units.RANGE_MICROGRAMS_PER_CUBIC_METER
            }
        } else {
            defaultView()
        }
    }
    
    
    func populateView() {
//        labelName.text = reading!.getName()
        navigationItem.title = reading!.getName()
        let type = reading!.getReadableType()
        switch type {
        case .ADDRESS:
            addressView(reading as! SimpleAddress)
        case .SPECK:
            speckView(reading as! Speck)
        default:
            NSLog("WARNING - could not populate view; unknown readable type")
        }
    }
    
    
    // MARK: Storyboard Events

    
    @IBAction func onClickFeedName(sender: UITapGestureRecognizer) {
        if let feed = closestFeed {
            let dialog = UIAlertView.init(title: feed.getName(), message: "Latitude: \(feed.location.latitude.description)\nLongitude: \(feed.location.longitude.description)", delegate: nil, cancelButtonTitle: "OK")
            dialog.show()
        }
    }
    
    
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