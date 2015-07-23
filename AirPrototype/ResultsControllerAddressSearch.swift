//
//  ResultsControllerAddressSearch.swift
//  AirPrototype
//
//  Created by mtasota on 7/15/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ResultsControllerAddressSearch: UITableViewController, UISearchResultsUpdating {
    
    // keeps track of results from search
    var myList = Array<SimpleAddress>()
    
    var searchText: String?
    var timer: NSTimer?
    
    
    func timerExpires() {
        let input = self.searchText!
        var url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        func completionHandler (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void {
            let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as? NSDictionary
            var results = JsonParser.parseAddressesFromJson(data!)
            myList.removeAll()
            for value in results {
                myList.append(value)
            }
            tableView.reloadData()
        }
        HttpRequestHandler.sharedInstance.sendJsonRequest(url!, completionHandler: completionHandler)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let text = searchController.searchBar.text
        if text == "" {
            if let timer = self.timer {
                timer.invalidate()
            }
        } else {
            let currentTime = Int64(NSDate().timeIntervalSince1970*1000)
            if let timer = self.timer {
                timer.invalidate()
            }
            self.searchText = text
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("timerExpires"), userInfo: nil, repeats: false)
        }
    }
    
}
