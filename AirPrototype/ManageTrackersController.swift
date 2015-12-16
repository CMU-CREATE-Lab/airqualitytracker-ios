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
    
    
    func removeReading(reading: Readable) {
        GlobalHandler.sharedInstance.headerReadingsHashMap.removeReading(reading)
        if reading.getReadableType() == .ADDRESS {
            AddressDbHelper.deleteAddressFromDb(reading as! SimpleAddress)
        } else if reading.getReadableType() == .SPECK {
            let speck = reading as! Speck
            SpeckDbHelper.deleteSpeckFromDb(speck)
            SettingsHandler.sharedInstance.addToBlacklistedDevices(speck.deviceId)
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func onSwitchUserCurrentLocation(sender: AnyObject) {
        SettingsHandler.sharedInstance.setAppUsesCurrentLocation(currentLocationSwitch.on)
    }
    
    
    // MARK: UIView Overrides
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: true)
        currentLocationSwitch.on = SettingsHandler.sharedInstance.appUsesLocation
    }
    
    
    // MARK table view
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
            let reading = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[indexPath.section]]![indexPath.row]
            self.removeReading(reading)
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return GlobalHandler.sharedInstance.headerReadingsHashMap.headers.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
        if let readings = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[section]] {
            return readings.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.HEADER_TITLES[section]
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TrackerReuse"
        let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
        let readings = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[indexPath.section]]!
        
        var cell: ManageTrackersTableViewCell?
        
        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ManageTrackersTableViewCell
        if cell == nil {
            cell = ManageTrackersTableViewCell()
        }
        cell?.populate(readings[indexPath.row], tableView: tableView)
        cell?.setEditing(true, animated: true)
        return cell!
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
        let from = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[sourceIndexPath.section]]![sourceIndexPath.row]
        let to = headerReadingsHashmap.adapterListTracker[headerReadingsHashmap.headers[destinationIndexPath.section]]![destinationIndexPath.row]
        GlobalHandler.sharedInstance.headerReadingsHashMap.reorderReading(from, destination: to)
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        // force moving in same sections ONLY
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
}