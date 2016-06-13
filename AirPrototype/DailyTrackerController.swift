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
    @IBOutlet weak var webView: UIWebView!
    var pickerValues = ["Mean", "Median", "Max"]
    var address: SimpleAddress?
    var displayType = Constants.DIRTY_DAYS_VALUE_TYPE
    
    
    private func constructColorsList() -> String {
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
                    let aqiReading = AQIReading(reading: reading)
                    result += aqiReading.getAqiHexString()
                }
            }
            // next value (even if empty day, then just an empty string)
            result += ",";
            
        }
        result = result.substringToIndex(result.endIndex.predecessor())
        
        NSLog("returning color list=\(result)")
        return result
    }
    
    
    private func onSelected(string: String) {
        // change displayType based on selected string
        if string == "Mean" {
            displayType = DayFeedValue.DaysValueType.MEAN
        } else if string == "Median" {
            displayType = DayFeedValue.DaysValueType.MEDIAN
        } else if string == "Max" {
            displayType = DayFeedValue.DaysValueType.MAX
        } else {
            NSLog("ERROR - Failed to grab selected; defaulting to dirty days.")
            displayType = Constants.DIRTY_DAYS_VALUE_TYPE
        }
        
        // get list of colors
        let colorsList = constructColorsList()
        // get local path of our HTML file
        let localPath = NSBundle.mainBundle().pathForResource("daily_tracker_grid", ofType: "html")
        // add params (color list)
        let params = "?table-colors=\(colorsList)"
        let urlWithParams = localPath?.stringByAppendingString(params)
        let url = NSURL(string: urlWithParams!)
        let urlRequest = NSURLRequest(URL: url!)
        webView.loadRequest(urlRequest)
    }
    
    
    // MARK: UIViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("DailyTrackerController did load")
        
        pickerView.dataSource = self
        pickerView.delegate = self
        navigationItem.title = "Trends: \(address!.getName())"
        
        onSelected(pickerValues[0])
    }
    
    
    // MARK: UIPickerView
    
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("Did select row \(pickerValues[row])")
        onSelected(pickerValues[row])
    }
    
}