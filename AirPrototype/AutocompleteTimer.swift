//
//  AutocompleteTimer.swift
//  AirPrototype
//
//  Created by mtasota on 10/15/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class AutocompleteTimer: NSObject, Timer {
    
    var timer:NSTimer?
    var timerInterval: NSTimeInterval
    var timerTolerance: NSTimeInterval?
    var controller: ResultsControllerAddressSearch
    
    
    private func completionHandler (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
        NSLog("In completionHandler \(self.description)")
        let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
        let results = JsonParser.parseAddressesFromJson(data!)
        
        self.controller.searchResultsList.removeAll()
        for value in results {
            self.controller.searchResultsList.append(value)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.controller.tableView.reloadData()
        }
    }
    
    
    init(controller: ResultsControllerAddressSearch, interval: NSTimeInterval, withTolerance: NSTimeInterval?) {
        self.timerInterval = interval
        self.timerTolerance = withTolerance
        self.controller = controller
    }
    
    
    func timerExpires() {
        NSLog("In timerExpires()")
        let input = self.controller.searchText!
        GlobalHandler.sharedInstance.httpRequestHandler.requestGeocodingFromApi(input, completionHandler: self.completionHandler)
    }
    
    
    func startTimer() {
        self.stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timerInterval, target: self, selector: Selector("timerExpires"), userInfo: nil, repeats: false)
        if let tolerance = self.timerTolerance {
            self.timer!.tolerance = tolerance
        }
    }
    
    
    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
    
}