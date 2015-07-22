//
//  ResultsControllerAddressSearch.swift
//  AirPrototype
//
//  Created by mtasota on 7/15/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
//import MapKit
//
//class ResultsControllerAddressSearch: UITableViewController, UISearchResultsUpdating {
//    
//    let handler: MKLocalSearchCompletionHandler = {(response: MKLocalSearchResponse!, error: NSError!) in
//        if error == nil {
//            for mapItem in response.mapItems {
//                NSLog("Name: \(mapItem.name)")
//            }
//        } else {
//            NSLog("error is not nil: \(error.localizedDescription)")
//        }
//    }
//    
//    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let text = searchController.searchBar.text
//        NSLog("updateSearchResultsForSearchController with text " + text)
//        var searchRequest = MKLocalSearchRequest.alloc()
//        searchRequest.naturalLanguageQuery = text
//        var localSearch = MKLocalSearch(request: searchRequest)
//        localSearch.startWithCompletionHandler(handler)
//    }
//    
//}

import CoreLocation

class ResultsControllerAddressSearch: UITableViewController, UISearchResultsUpdating {
    
    var searchText: String?
//    var textLastChanged: Int64?
    var timer: NSTimer?
    
    
    func timerExpires() {
        let input = self.searchText!
        var url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        func completionHandler (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void {
            // TODO handle response by parsing JSON and populating list items
            NSLog("got response (header): " + response.description)
            NSLog("got datafile: " + url.description)
            
            let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as? NSDictionary
            NSLog("data response=" + data!.description)
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
//            self.textLastChanged = currentTime
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("timerExpires"), userInfo: nil, repeats: false)
        }
    }
    
}
