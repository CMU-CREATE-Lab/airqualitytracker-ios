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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("DailyTrackerController did load")
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let localPath = NSBundle.mainBundle().pathForResource("daily_tracker_grid", ofType: "html")
        let params = "?table-colors=ffffff,000000,ffffff,000000,ffffff,000000,ffffff,000000"
        let urlWithParams = localPath?.stringByAppendingString(params)
        NSLog("PATH=\(urlWithParams)")
        
        let url = NSURL(string: urlWithParams!)
        let urlRequest = NSURLRequest(URL: url!)
        webView.loadRequest(urlRequest)
    }
    
    
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
    }
    
}