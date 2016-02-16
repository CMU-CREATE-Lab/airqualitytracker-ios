//
//  GlobalHandler.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GlobalHandler {
    
    // MARK: singleton pattern; this is the only time the class should be initialized
    static var singletonInstantiated: Bool = false
    class var sharedInstance: GlobalHandler {
        struct Singleton {
            static let instance = GlobalHandler()
        }
        return Singleton.instance
    }
    
    
    // MARK: Class Functions
    

    // managed global instances
    var airNowRequestHandler: AirNowRequestHandler
    var esdrAuthHandler: EsdrAuthHandler
    var esdrFeedsHandler: EsdrFeedsHandler
    var esdrLoginHandler: EsdrLoginHandler
    var esdrSpecksHandler: EsdrSpecksHandler
    var esdrTilesHandler: EsdrTilesHandler
    var httpRequestHandler: HttpRequestHandler
    var positionIdHelper: PositionIdHelper
    var servicesHandler: ServicesHandler
    var settingsHandler: SettingsHandler
    // data structure
    var readingsHandler: ReadingsHandler
    var esdrAccount: EsdrAccount
    // keep track of ALL adapters for notify
    var readableIndexListView: UICollectionView?
    var secretDebugMenuTable: UITableView?
    var loginController: LoginController?
    var appDelegate: AppDelegate
    var refreshTimer: RefreshTimer
    
    
    private init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as! AppDelegate)
        // global instances
        airNowRequestHandler = AirNowRequestHandler()
        esdrAuthHandler = EsdrAuthHandler()
        esdrSpecksHandler = EsdrSpecksHandler()
        esdrFeedsHandler = EsdrFeedsHandler()
        esdrTilesHandler = EsdrTilesHandler()
        httpRequestHandler = HttpRequestHandler()
        servicesHandler = ServicesHandler()
        settingsHandler = SettingsHandler()
        esdrLoginHandler = EsdrLoginHandler()
        positionIdHelper = PositionIdHelper()
        // data structures
        esdrAccount = EsdrAccount(userDefaults: settingsHandler.userDefaults)
        // NOTICE: in Swift, we cannot pass the object before it inits. Instead, we pass the value we actually care about in HRHM's constructor
        readingsHandler = ReadingsHandler()
        GlobalHandler.singletonInstantiated = true
        // expires in 5 minutes, with tolerance up to 30 seconds
        self.refreshTimer = RefreshTimer(interval: 300.0, withTolerance: 30.0)
    }
    
    
    func removeReading(reading: Readable) {
        readingsHandler.removeReading(reading)
        if reading.getReadableType() == .ADDRESS {
            AddressDbHelper.deleteAddressFromDb(reading as! SimpleAddress)
        } else if reading.getReadableType() == .SPECK {
            let speck = reading as! Speck
            SpeckDbHelper.deleteSpeckFromDb(speck)
            settingsHandler.addToBlacklistedDevices(speck.deviceId)
        }
    }
    
    
    func updateReadings() {
        // check expiresAt timer and determine if we should update tokens (within threshold)
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let expiredAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            let timeRemaining = expiredAt - timestamp
            if timeRemaining <= 0 {
                esdrLoginHandler.setUserLoggedIn(false)
                esdrAccount.clear()
                UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
            } else if timeRemaining <= Constants.ESDR_TOKEN_TIME_TO_UPDATE_ON_REFRESH {
                let refreshToken = GlobalHandler.sharedInstance.esdrAccount.refreshToken!
                
                func responseHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                    if error != nil {
                        NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                    } else {
                        let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                        let access_token = data!.valueForKey("access_token") as? String
                        let refresh_token = data!.valueForKey("refresh_token") as? String
                        let expires_in = data!.valueForKey("expires_in") as? Int
                        if access_token != nil && refresh_token != nil && expires_in != nil {
                            NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                            GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                            NSLog("Updated ESDR Tokens!")
                        } else {
                            GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                            NSLog("Failed to grab access/refresh token(s)")
                        }
                    }
                }
                
                GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
            }
        }
        
        // Now, perform readings update
        readingsHandler.updateAddresses()
        readingsHandler.updateSpecks()
        if GlobalHandler.sharedInstance.settingsHandler.appUsesLocation {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdateFeeds(readingsHandler.gpsReadingHandler.gpsAddress)
        }
        self.refreshTimer.startTimer()
    }
    
    
    func notifyGlobalDataSetChanged() {
        if let readableIndexListView = self.readableIndexListView {
            dispatch_async(dispatch_get_main_queue()) {
                readableIndexListView.reloadData()
            }
        }
        // TODO this looks like it crashes from EXC_BAD_ACCESS (probably upon refreshing feeds)
        if let secretMenu = self.secretDebugMenuTable {
            dispatch_async(dispatch_get_main_queue()) {
                // (crashes here)
                secretMenu.reloadData()
            }
        }
    }
    
}