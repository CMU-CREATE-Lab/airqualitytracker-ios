//
//  AirNowDetailsController.swift
//  AirPrototype
//
//  Created by mtasota on 3/1/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AirNowDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reading: AirNowReadable?
    var observations: [AirNowObservation]?
    
    // TODO table implementation
    @IBOutlet var tableAirNowObservations: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("AirNowDetailsController did load with reading=\(reading!.getName())")
        observations = reading!.getMostRecentAirNowObservations()
        NSLog("observations count=\(observations!.count)")
        if observations!.count == 0 {
            NSLog("Requesting observations from airnow")
            reading!.requestAirNow()
        } else {
            for item in observations! {
                NSLog("aqi=\(item.aqi), time=\(item.observedDateTime), location=\(item.location), paramName=\(item.parameterName)")
            }
        }
        
        tableAirNowObservations.delegate = self
        tableAirNowObservations.dataSource = self
//        GlobalHandler.sharedInstance.secretDebugMenuTable = tableView
    }
    
    
    // MARK table view
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations!.count
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if observations!.count > 0 {
            // TODO make pretty
            return observations![0].observedDateTime.description
        }
        return "No AirNow observations"
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "AirNowDetailsCell"
        var cell: AirNowDetailsTableCell?
        let observation = observations![indexPath.row]
        
        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? AirNowDetailsTableCell
        if cell == nil {
            cell = AirNowDetailsTableCell()
        }
        cell?.populate(observation)
        return cell!
    }
    
}