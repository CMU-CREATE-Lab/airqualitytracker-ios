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
    var esdrHoneybeesHandler: EsdrHoneybeesHandler
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
    var airNowTable: UITableView?
    var loginController: LoginController?
    var appDelegate: AppDelegate
    var refreshTimer: RefreshTimer
    
    
    fileprivate init() {
        appDelegate = (UIApplication.shared.delegate! as! AppDelegate)
        // global instances
        airNowRequestHandler = AirNowRequestHandler()
        esdrAuthHandler = EsdrAuthHandler()
        esdrSpecksHandler = EsdrSpecksHandler()
        esdrHoneybeesHandler = EsdrHoneybeesHandler()
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
    
    
    func updateReadings() {
        // check expiresAt timer and determine if we should update tokens (within threshold)
        if settingsHandler.userLoggedIn {
            let timestamp = Int(Date().timeIntervalSince1970)
            let expiredAt = esdrAccount.expiresAt!
            let timeRemaining = expiredAt - timestamp
            if timeRemaining <= Constants.ESDR_TOKEN_TIME_TO_UPDATE_ON_REFRESH {
                let refreshToken = esdrAccount.refreshToken!
                
                func responseHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                    if error != nil {
                        esdrLoginHandler.updateEsdrTokens("", refreshToken: "", expiresAt: 0)
                        NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                    } else if let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary {
                        let access_token = data.value(forKey: "access_token") as? String
                        let refresh_token = data.value(forKey: "refresh_token") as? String
                        let expires_in = data.value(forKey: "expires_in") as? Int
                        if access_token != nil && refresh_token != nil && expires_in != nil {
                            NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                            esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                            NSLog("Updated ESDR Tokens!")
                        } else {
                            esdrLoginHandler.removeEsdrAccount()
                            NSLog("Failed to grab access/refresh token(s)")
                        }
                    }
                }
                
                esdrAuthHandler.requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
            }
        }
        
        // Now, perform readings update
        readingsHandler.updateAddresses()
        readingsHandler.updateSpecks()
        if settingsHandler.appUsesLocation {
            esdrFeedsHandler.requestUpdate(readingsHandler.gpsReadingHandler.gpsAddress)
        }
        self.refreshTimer.startTimer()
    }
    
    
    func notifyGlobalDataSetChanged() {
        if let readableIndexListView = self.readableIndexListView {
            DispatchQueue.main.async {
                readableIndexListView.reloadData()
            }
        }
        if let secretMenu = self.secretDebugMenuTable {
            DispatchQueue.main.async {
                // (crashes here)
                secretMenu.reloadData()
            }
        }
        if let airNowMenu = self.airNowTable {
            DispatchQueue.main.async {
                airNowMenu.reloadData()
            }
        }
    }
    
}
