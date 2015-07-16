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
    
    let handler: CLGeocodeCompletionHandler = {(response: [AnyObject]!, error: NSError!) in
        if error == nil {
            for placemark in response {
                let temp = placemark as! CLPlacemark
                NSLog("got placemark \(temp.name)")
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let text = searchController.searchBar.text
        NSLog("updateSearchResultsForSearchController with text " + text)
        
        CLGeocoder().geocodeAddressString(text, completionHandler: handler)
    }
}

