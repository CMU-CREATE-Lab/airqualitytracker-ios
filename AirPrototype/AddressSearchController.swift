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

    @IBOutlet var navItemAddressSearch: UINavigationItem!
    var resultsController: ResultsControllerAddressSearch!
    var searchControllerAddressSearch: UISearchController?
    
    
    // MARK: UIView Overrides
    
    
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
        
        resultsController.tableView.register(UINib(nibName: "ResultsTableViewCellAddressSearch", bundle: nil), forCellReuseIdentifier: Constants.CellReuseIdentifiers.ADDRESS_SEARCH)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: SearchBar delegate
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        resultsController.tableView.reloadData()
    }
    
}
