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

class ResultsControllerAddressSearch: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    // keeps track of results from search
    var myList = Array<SimpleAddress>()
    
    var addressSearchController: AddressSearchController?
    var searchText: String?
    var timer: NSTimer?
    
    
    func timerExpires() {
        NSLog("In timerExpires()")
        let input = self.searchText!
        var url = NSURL(string: "http://autocomplete.wunderground.com/aq?query=\(input)&c=US".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        HttpRequestHandler.sharedInstance.sendJsonRequest(url!, completionHandler: self.completionHandler)
    }
    
    
    func completionHandler (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void {
        NSLog("In completionHandler \(self.description)")
        let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as? NSDictionary
        var results = JsonParser.parseAddressesFromJson(data!)
        
        myList.removeAll()
        for value in results {
            myList.append(value)
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
        return myList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = Constants.CellReuseIdentifiers.ADDRESS_SEARCH
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ResultsTableViewCellAddressSearch
        cell.populate(myList[indexPath.row])
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("adding clicked address to list and returning to AddressList")
        GlobalHandler.sharedInstance.addressFeedsHashMap.addAddress(myList[indexPath.row])
        DatabaseHelper.addAddressToDb(myList[indexPath.row])
        addressSearchController!.navigationController?.popViewControllerAnimated(true)
    }
    
}
