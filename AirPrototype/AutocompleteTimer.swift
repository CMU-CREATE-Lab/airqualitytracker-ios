//
//  AutocompleteTimer.swift
//  AirPrototype
//
//  Created by mtasota on 10/15/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class AutocompleteTimer: NSObject, Timer {
    
    var timer:Foundation.Timer?
    var timerInterval: TimeInterval
    var timerTolerance: TimeInterval?
    var controller: ResultsControllerAddressSearch
    
    
    fileprivate func completionHandler (_ url: URL?, response: URLResponse?, error: Error?) -> Void {
        let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
        let results = WuJsonParser.parseAddressesFromJson(data!)
        
        self.controller.searchResultsList.removeAll()
        for value in results {
            self.controller.searchResultsList.append(value)
        }
        
        DispatchQueue.main.async {
            self.controller.tableView.reloadData()
        }
    }
    
    
    init(controller: ResultsControllerAddressSearch, interval: TimeInterval, withTolerance: TimeInterval?) {
        self.timerInterval = interval
        self.timerTolerance = withTolerance
        self.controller = controller
    }
    
    
    func timerExpires() {
        let input = self.controller.searchText!
        GlobalHandler.sharedInstance.httpRequestHandler.requestGeocodingFromApi(input, completionHandler: self.completionHandler)
    }
    
    
    func startTimer() {
        self.stopTimer()
        self.timer = Foundation.Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(AutocompleteTimer.timerExpires), userInfo: nil, repeats: false)
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
