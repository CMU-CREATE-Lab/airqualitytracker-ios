//
//  AddressSearchController.swift
//  AirPrototype
//
//  Created by mtasota on 7/14/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

//class AddressSearchController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITableViewDelegate {
class AddressSearchController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {

    @IBOutlet var navItemAddressSearch: UINavigationItem!
    @IBOutlet var tableViewAddressSearch: UITableView!
    @IBOutlet var myView: UIView!
    @IBOutlet var resultsController: ResultsControllerAddressSearch!
    var myList = Array<SimpleAddress>()
    var searchControllerAddressSearch: UISearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsController = ResultsControllerAddressSearch()
        searchControllerAddressSearch = UISearchController(searchResultsController: resultsController)
//        resultsController.tableView = tableViewAddressSearch
        searchControllerAddressSearch!.searchResultsUpdater = resultsController
//        tableViewAddressSearch.tableHeaderView = searchControllerAddressSearch!.searchBar
//        searchControllerAddressSearch!.searchBar.sizeToFit()
        searchControllerAddressSearch!.searchBar.delegate = self
        searchControllerAddressSearch!.hidesNavigationBarDuringPresentation = false
        
        navItemAddressSearch.titleView = searchControllerAddressSearch!.searchBar
        
        self.definesPresentationContext = true
        
//        resultsController.tableView = UITableView()
//        resultsController.tableView.delegate = self
//        resultsController.tableView.dataSource = self
//        resultsController.tableView.registerClass(AddressSearchTableViewCell.self, forCellReuseIdentifier: "reuseAddressSearch")
        
        var temp = SimpleAddress()
        temp.name = "Test"
        myList.append(temp)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        NSLog("searchBarSearchButtonClicked")
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        NSLog("searchBarTextDidEndEditing")
    }
    
    
    
    //MARK: - Segue for Cancel Button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("searchBarCancelButtonClicked")
        //        performSegueWithIdentifier("dismissAndCancel", sender: self)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "reuseAddressSearch"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddressSearchTableViewCell
        
        cell.populate(myList[indexPath.row])
        return cell
    }
    
}