//
//  SecretMenuController.swift
//  AirPrototype
//
//  Created by mtasota on 10/29/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SecretMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var labelUsername: UILabel!
    @IBOutlet var labelUserId: UILabel!
    @IBOutlet var labelAccessToken: UILabel!
    @IBOutlet var labelRefreshToken: UILabel!
    @IBOutlet var labelDeviceIdIgnoreList: UILabel!
    @IBOutlet var labelAppVersion: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBAction func clickRequestFeeds(sender: AnyObject) {
        var feeds = [Feed]()
        if let addresses = GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[1]] {
            for reading in addresses {
                feeds.appendContentsOf( (reading as! SimpleAddress).feeds )
            }
        }
        for feed in feeds {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestChannelReading(feed, channel: feed.channels[0])
        }
    }
    
    
    override func viewDidLoad() {
        let username = GlobalHandler.sharedInstance.settingsHandler.username
        let userId = GlobalHandler.sharedInstance.settingsHandler.userId!.description
        let accessToken = GlobalHandler.sharedInstance.settingsHandler.accessToken
        let refreshToken = GlobalHandler.sharedInstance.settingsHandler.refreshToken
        var deviceList = ""
        if let list = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            deviceList = list.description
        }
        
        labelUsername.text = username
        labelUserId.text = userId
        labelAccessToken.text = accessToken
        labelRefreshToken.text = refreshToken
        labelDeviceIdIgnoreList.text = deviceList
        labelAppVersion.text = Constants.APP_VERSION_NUMBER
        
        tableView.delegate = self
        tableView.dataSource = self
        GlobalHandler.sharedInstance.secretDebugMenuTable = tableView
    }
    
    override func viewDidDisappear(animated: Bool) {
        GlobalHandler.sharedInstance.secretDebugMenuTable = nil
    }
    
    
    // MARK table view
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let addresses = GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[1]] {
            return addresses.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        if let addresses = readingsHandler.adapterList[Constants.HEADER_TITLES[1]] {
            if addresses[section].getReadableType() == ReadableType.ADDRESS {
                let address = addresses[section] as! SimpleAddress
                return address.feeds.count
            }
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let address = (GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[1]]!)[section] as! SimpleAddress
        return "\(section.description) (\(address.location.latitude.description),\(address.location.longitude.description))"
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "SecretMenuCell"
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let address = (readingsHandler.adapterList[Constants.HEADER_TITLES[1]]!)[indexPath.section] as! SimpleAddress
        let feed = address.feeds[indexPath.row]
        
        var cell: SecretMenuTableCell?

        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SecretMenuTableCell
        if cell == nil {
            cell = SecretMenuTableCell()
        }
        cell?.populate(feed, fromAddress: address, tableView: tableView)
        return cell!
    }
    
}