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
    var esdrAuthHandler: EsdrAuthHandler
    var esdrSpecksHandler: EsdrSpecksHandler
    var esdrFeedsHandler: EsdrFeedsHandler
    var httpRequestHandler: HttpRequestHandler
    var servicesHandler: ServicesHandler
    var settingsHandler: SettingsHandler
    var esdrLoginHandler: EsdrLoginHandler
    var positionIdHelper: PositionIdHelper
    // data structure
    var headerReadingsHashMap: HeaderReadingsHashMap
    // keep track of ALL adapters for notify
    var readableIndexListView: UICollectionView?
    var secretDebugMenuTable: UITableView?
    var appDelegate: AppDelegate
    var refreshTimer: RefreshTimer
    
    
    private init() {
        appDelegate = (UIApplication.sharedApplication().delegate! as! AppDelegate)
        // global instances
        esdrAuthHandler = EsdrAuthHandler()
        esdrSpecksHandler = EsdrSpecksHandler()
        esdrFeedsHandler = EsdrFeedsHandler()
        httpRequestHandler = HttpRequestHandler()
        servicesHandler = ServicesHandler()
        settingsHandler = SettingsHandler()
        esdrLoginHandler = EsdrLoginHandler()
        positionIdHelper = PositionIdHelper()
        // data structures
        // NOTICE: in Swift, we cannot pass the object before it inits. Instead, we pass the value we actually care about in HRHM's constructor
        headerReadingsHashMap = HeaderReadingsHashMap(appUsesLocation: settingsHandler.appUsesLocation)
        GlobalHandler.singletonInstantiated = true
        // expires in 5 minutes, with tolerance up to 30 seconds
        self.refreshTimer = RefreshTimer(interval: 300.0, withTolerance: 30.0)
    }
    
    
    func updateReadings() {
        headerReadingsHashMap.updateAddresses()
        headerReadingsHashMap.updateSpecks()
        if GlobalHandler.sharedInstance.settingsHandler.appUsesLocation {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdateFeeds(headerReadingsHashMap.gpsAddress)
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