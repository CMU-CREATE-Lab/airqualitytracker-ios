//
//  ResultsControllerAddressSearch.swift
//  AirPrototype
//
//  Created by mtasota on 7/15/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ResultsControllerAddressSearch: UITableViewController, UISearchResultsUpdating {
    
    // keeps track of results from search
    var searchResultsList = Array<SimpleAddress>()
    var addressSearchController: AddressSearchController?
    var searchText: String?
    var timer: NSTimer?
    
    
    func timerExpires() {
        NSLog("In timerExpires()")
        let input = self.searchText!
        HttpRequestHandler.sharedInstance.requestGeocodingFromApi(input, completionHandler: self.completionHandler)
    }
    
    
    func completionHandler (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
        NSLog("In completionHandler \(self.description)")
        let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
        let results = JsonParser.parseAddressesFromJson(data!)
        
        searchResultsList.removeAll()
        for value in results {
            searchResultsList.append(value)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
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
    
    // MARK: UITableView delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = Constants.CellReuseIdentifiers.ADDRESS_SEARCH
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ResultsTableViewCellAddressSearch
        cell.populate(searchResultsList[indexPath.row])
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("adding clicked address to list and returning to AddressList")
        
        // add to database and data structure
        DatabaseHelper.addAddressToDb(searchResultsList[indexPath.row])
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.headerReadingsHashMap.addReading(searchResultsList[indexPath.row])
        globalHandler.updateReadings()
        
        // finish
        addressSearchController!.navigationController?.popViewControllerAnimated(true)
    }
    
}
