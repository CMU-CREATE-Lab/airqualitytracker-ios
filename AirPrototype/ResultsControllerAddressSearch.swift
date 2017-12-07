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
    
    var searchResultsList = Array<SimpleAddress>()
    var addressSearchController: AddressSearchController?
    var searchText: String?
    var autocompleteTimer: AutocompleteTimer?
    
    
    func updateSearchResults(for searchController: UISearchController) {
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = Constants.CellReuseIdentifiers.ADDRESS_SEARCH
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ResultsTableViewCellAddressSearch
        cell.populate(searchResultsList[indexPath.row])
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // add to database and data structure
        AddressDbHelper.addAddressToDb(searchResultsList[indexPath.row])
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.readingsHandler.addReading(searchResultsList[indexPath.row])
        globalHandler.updateReadings()
        
        // finish
        addressSearchController!.navigationController?.popViewController(animated: true)
    }
    
}
