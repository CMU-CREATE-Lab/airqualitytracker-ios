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
    @IBOutlet var labelExpiresAt: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBAction func clickRequestFeeds(_ sender: AnyObject) {
        var feeds = [AirQualityFeed]()
        if let addresses = GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[2]] {
            for reading in addresses {
                feeds.append( contentsOf: (reading as! SimpleAddress).feeds )
            }
        }
        for feed in feeds {
            if feed.hasReadablePm25Value() {
                GlobalHandler.sharedInstance.esdrFeedsHandler.requestChannelReading(feed, channel: feed.getPm25Channels().first! as Pm25Channel)
            }
        }
    }
    
    
    override func viewDidLoad() {
        let username = GlobalHandler.sharedInstance.esdrAccount.username
        let userId = GlobalHandler.sharedInstance.esdrAccount.userId!.description
        let accessToken = GlobalHandler.sharedInstance.esdrAccount.accessToken
        let refreshToken = GlobalHandler.sharedInstance.esdrAccount.refreshToken
        let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!.description
        var deviceList = ""
        if let list = GlobalHandler.sharedInstance.settingsHandler.blacklistedDevices {
            deviceList = list.description
        }
        
        labelUsername.text = username
        labelUserId.text = userId
        labelExpiresAt.text = expiresAt
        labelAccessToken.text = accessToken
        labelRefreshToken.text = refreshToken
        labelDeviceIdIgnoreList.text = deviceList
        labelAppVersion.text = Constants.APP_VERSION_NUMBER
        
        tableView.delegate = self
        tableView.dataSource = self
        GlobalHandler.sharedInstance.secretDebugMenuTable = tableView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GlobalHandler.sharedInstance.secretDebugMenuTable = nil
    }
    
    
    // MARK table view
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let addresses = GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[2]] {
            return addresses.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        if let addresses = readingsHandler.adapterList[Constants.HEADER_TITLES[2]] {
            if (addresses[section] is SimpleAddress) {
                let address = addresses[section] as! SimpleAddress
                return address.feeds.count
            }
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let address = (GlobalHandler.sharedInstance.readingsHandler.adapterList[Constants.HEADER_TITLES[2]]!)[section] as! SimpleAddress
        return "\(section.description) (\(address.location.latitude.description),\(address.location.longitude.description))"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SecretMenuCell"
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let address = (readingsHandler.adapterList[Constants.HEADER_TITLES[2]]!)[indexPath.section] as! SimpleAddress
        let feed = address.feeds[indexPath.row]
        
        var cell: SecretMenuTableCell?

        cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SecretMenuTableCell
        if cell == nil {
            cell = SecretMenuTableCell()
        }
        cell?.populate(feed, fromAddress: address, tableView: tableView)
        return cell!
    }
    
}
