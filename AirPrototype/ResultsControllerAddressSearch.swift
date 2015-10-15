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
    var autocompleteTimer: AutocompleteTimer?
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let text = searchController.searchBar.text
        if text == "" {
            if let timer = autocompleteTimer {
                timer.stopTimer()
            }
        } else {
            if let timer = autocompleteTimer {
                timer.stopTimer()
            }
            self.searchText = text
            self.autocompleteTimer = AutocompleteTimer(controller: self, interval: 0.2, withTolerance: nil)
            self.autocompleteTimer!.startTimer()
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
