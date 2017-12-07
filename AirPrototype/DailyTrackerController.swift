//
//  DailyTrackerController.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/16/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class DailyTrackerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var scalePickerView: UIPickerView!
    @IBOutlet weak var webView: UIWebView!
    let pickerValues = ["Max", "Median", "Mean"]
    let scalePickerValues = ["EPA AQI", "WHO"]
    var address: SimpleAddress?
    var displayType = Constants.DIRTY_DAYS_VALUE_TYPE
    var scaleType = ScaleType.epa_AQI
    
    
    fileprivate func constructColorsList() -> String {
        var result = ""
        // TODO check for nil tracker
        let values = address!.dailyFeedTracker!.values
        
        var index = 0;
        var startTime = address!.dailyFeedTracker!.getStartTime()
        let list = [Int](0...364)
        for _ in list {
            startTime += Constants.TWENTY_FOUR_HOURS
            
            // only check for values we still have
            if (index<values.count) {
                let value = values[index]
                // add color value if value was in the past day
                if (value.time <= startTime) {
                    index += 1
                    let reading = value.getCount(displayType)
                    switch (scaleType) {
                        case .epa_AQI:
                            let aqiReading = AQIReading(reading: reading)
                            result += aqiReading.getAqiHexString()
                        case .who:
                            let whoReading = WHOReading(reading: reading)
                            result += whoReading.getAqiHexString()
                        default:
                            NSLog("ERROR - Unrecognized ScaleType for Daily Tracker colors list.")
                    }
                }
            }
            // next value (even if empty day, then just an empty string)
            result += ",";
            
        }
        result = result.substring(to: result.characters.index(before: result.endIndex))
        
        NSLog("returning color list=\(result)")
        return result
    }
    
    
    fileprivate func onSelected(_ string: String) {
        // change displayType based on selected string
        if string == "Mean" {
            displayType = DayFeedValue.DaysValueType.mean
        } else if string == "Median" {
            displayType = DayFeedValue.DaysValueType.median
        } else if string == "Max" {
            displayType = DayFeedValue.DaysValueType.max
        } else if string == "EPA AQI" {
            scaleType = ScaleType.epa_AQI
        } else if string == "WHO" {
            scaleType = ScaleType.who
        } else {
            NSLog("ERROR - Failed to grab selected; defaulting to dirty days.")
            displayType = Constants.DIRTY_DAYS_VALUE_TYPE
        }
        
        // get list of colors
        let colorsList = constructColorsList()
        // get local path of our HTML file
        let localPath = Bundle.main.path(forResource: "daily_tracker_grid", ofType: "html")
        // add params (color list)
        let params = "?table-colors=\(colorsList)"
        let urlWithParams = (localPath)! + params
        let url = URL(string: urlWithParams)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    
    // MARK: UIViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("DailyTrackerController did load")
        
        pickerView.dataSource = self
        pickerView.delegate = self
        scalePickerView.dataSource = self
        scalePickerView.delegate = self
        navigationItem.title = "Trends: \(address!.getName())"
        
        onSelected(pickerValues[0])
    }
    
    
    // MARK: UIPickerView
    
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerView {
            return pickerValues.count
        } else if pickerView == self.scalePickerView {
            return scalePickerValues.count
        }
        return 0
    }
    
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerView {
            return pickerValues[row]
        } else if pickerView == self.scalePickerView {
            return scalePickerValues[row]
        }
        return nil
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.pickerView {
            NSLog("Did select row \(pickerValues[row])")
            onSelected(pickerValues[row])
        } else if pickerView == self.scalePickerView {
            NSLog("Did select row \(scalePickerValues[row])")
            onSelected(scalePickerValues[row])
        }
    }
    
}
