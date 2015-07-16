//
//  AddressSearchController.swift
//  AirPrototype
//
//  Created by mtasota on 7/14/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AddressSearchController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {

    // interface
    @IBOutlet var navItemAddressSearch: UINavigationItem!
    @IBOutlet var resultsController: ResultsControllerAddressSearch!
    var searchControllerAddressSearch: UISearchController?
    // keeps track of results from search
    var myList = Array<SimpleAddress>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsController = ResultsControllerAddressSearch()
        searchControllerAddressSearch = UISearchController(searchResultsController: resultsController)
        searchControllerAddressSearch!.searchResultsUpdater = resultsController
        searchControllerAddressSearch!.searchBar.delegate = self
        searchControllerAddressSearch!.hidesNavigationBarDuringPresentation = false
        
        navItemAddressSearch.titleView = searchControllerAddressSearch!.searchBar
        self.definesPresentationContext = true
        
        resultsController.tableView = UITableView()
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        resultsController.tableView.registerNib(UINib(nibName: "ResultsTableViewCellAddressSearch", bundle: nil), forCellReuseIdentifier: Constants.CellReuseIdentifiers.ADDRESS_SEARCH)
        
        var temp = SimpleAddress()
        temp.name = "Test"
        myList.append(temp)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: SearchBar delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        NSLog("searchBarSearchButtonClicked")
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        NSLog("searchBarTextDidEndEditing")
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("searchBarCancelButtonClicked")
    }
    
    
    // MARK: UITableView delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = Constants.CellReuseIdentifiers.ADDRESS_SEARCH
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ResultsTableViewCellAddressSearch
        cell.populate(myList[indexPath.row])
        return cell
    }
    
}