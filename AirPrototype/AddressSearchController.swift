//
//  AddressSearchController.swift
//  AirPrototype
//
//  Created by mtasota on 7/14/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AddressSearchController: UIViewController, UISearchBarDelegate {

    // interface
    @IBOutlet var navItemAddressSearch: UINavigationItem!
    var resultsController: ResultsControllerAddressSearch!
    var searchControllerAddressSearch: UISearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsController = ResultsControllerAddressSearch()
        resultsController.addressSearchController = self
        searchControllerAddressSearch = UISearchController(searchResultsController: resultsController)
        searchControllerAddressSearch!.searchResultsUpdater = resultsController
        searchControllerAddressSearch!.searchBar.delegate = self
        searchControllerAddressSearch!.hidesNavigationBarDuringPresentation = false
        
        navItemAddressSearch.titleView = searchControllerAddressSearch!.searchBar
        self.definesPresentationContext = true
        
        resultsController.tableView.registerNib(UINib(nibName: "ResultsTableViewCellAddressSearch", bundle: nil), forCellReuseIdentifier: Constants.CellReuseIdentifiers.ADDRESS_SEARCH)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: SearchBar delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        NSLog("searchBarSearchButtonClicked")
        resultsController.tableView.reloadData()
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        NSLog("searchBarTextDidEndEditing")
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("searchBarCancelButtonClicked")
    }
    
}