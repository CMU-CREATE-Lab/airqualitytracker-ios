//
//  ManageTrackersController.swift
//  AirPrototype
//
//  Created by mtasota on 10/19/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ManageTrackersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentLocationSwitch: UISwitch!
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func onSwitchUserCurrentLocation(_ sender: AnyObject) {
        GlobalHandler.sharedInstance.settingsHandler.setAppUsesCurrentLocation(currentLocationSwitch.isOn)
    }
    
    
    // MARK: UIView Overrides
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: true)
        currentLocationSwitch.isOn = GlobalHandler.sharedInstance.settingsHandler.appUsesLocation
    }
    
    
    // MARK table view
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let headerReadingsHashmap = GlobalHandler.sharedInstance.readingsHandler
            let reading = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[indexPath.section]]![indexPath.row]
            GlobalHandler.sharedInstance.readingsHandler.removeReading(reading)
            tableView.reloadData()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return GlobalHandler.sharedInstance.readingsHandler.headers.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        if let readings = readingsHandler.adapterListTracker[readingsHandler.headers[section]] {
            return readings.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GlobalHandler.sharedInstance.readingsHandler.headers[section]
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TrackerReuse"
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let readings = readingsHandler.adapterListTracker[readingsHandler.headers[indexPath.section]]!
        
        var cell: ManageTrackersTableViewCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ManageTrackersTableViewCell
        if cell == nil {
            cell = ManageTrackersTableViewCell()
        }
        cell?.populate(readings[indexPath.row], tableView: tableView)
        cell?.setEditing(true, animated: true)
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let from = readingsHandler.adapterListTracker[readingsHandler.headers[sourceIndexPath.section]]![sourceIndexPath.row]
        let to = readingsHandler.adapterListTracker[readingsHandler.headers[destinationIndexPath.section]]![destinationIndexPath.row]
        GlobalHandler.sharedInstance.readingsHandler.reorderReading(from, destination: to)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // force moving in same sections ONLY
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
}
