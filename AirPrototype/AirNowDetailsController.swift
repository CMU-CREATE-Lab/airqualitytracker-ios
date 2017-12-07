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
    
    @IBOutlet var tableAirNowObservations: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let observations = reading!.getMostRecentAirNowObservations()
        if observations.count == 0 {
            NSLog("Requesting observations from airnow for reading=\(reading!.getName())")
            reading!.requestAirNow()
        }
        
        tableAirNowObservations.delegate = self
        tableAirNowObservations.dataSource = self
        GlobalHandler.sharedInstance.airNowTable = tableAirNowObservations
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GlobalHandler.sharedInstance.airNowTable = nil
    }
    
    
    // MARK table view
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let observations = reading!.getMostRecentAirNowObservations()
        return observations.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let observations = reading!.getMostRecentAirNowObservations()
        if observations.count > 0 {
            let title = "observed at \(observations[0].readableDate)"
            return title
//            return observations[0].observedDateTime.description
        }
        return "No AirNow observations"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "AirNowDetailsCell"
        var cell: AirNowDetailsTableCell?
        let observations = reading!.getMostRecentAirNowObservations()
        let observation = observations[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AirNowDetailsTableCell
        if cell == nil {
            cell = AirNowDetailsTableCell()
        }
        cell?.populate(observation)
        return cell!
    }
    
}
