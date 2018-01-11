//
//  ReadableIndexController.swift
//  AirPrototype
//
//  Created by mtasota on 9/9/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class ReadableIndexController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet var gridView: UICollectionView!
    var refreshController: UIRefreshControl?
    var longPressActive = false
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        longPressActive = false
        if buttonIndex > 0 {
            self.navigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecretMenu"), animated: true)
        }
    }
    
    
    func refreshLayout() {
        GlobalHandler.sharedInstance.updateReadings()
        self.refreshController!.endRefreshing()
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func longPressOccurred(_ sender: UILongPressGestureRecognizer) {
        if !longPressActive {
            longPressActive = true
            let dialog = UIAlertView.init(title: "DEBUG", message: "View Debug Screen?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            dialog.show()
        }
    }

    
    @IBAction func menuClicked(_ sender: UIBarButtonItem) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsPopup") as! SettingsController
        // NOTE: preferred content size is controlled on SettingsController's viewDidLoad() function
        controller.parentNavigationController = self.navigationController
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        if let popover = controller.popoverPresentationController {
            popover.delegate = self
            popover.barButtonItem = sender
            popover.permittedArrowDirections = .any
            self.present(controller, animated: true, completion: nil)
            controller.view.sizeToFit()
        }
    }
    
    
    // MARK: UIView Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NOTICE: in Swiftland, we cannot call these functions
        // within GlobalHandler (since we cannot pass the reference 
        // until after init). Instead, we load from the DB here.
//        AddressDbHelper.loadAddressesFromDb()
//        SpeckDbHelper.loadSpecksFromDb()
//        HoneybeeDbHelper.loadHoneybeesFromDb()
        DatabaseHelper.loadFromDb()
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.readableIndexListView = self.gridView
        
        // manually sets login info for ESDR
        if Constants.ManualOverrides.MANUAL_ESDR_LOGIN {
            ManualOverrides.loginEsdr()
        }
        
        if globalHandler.esdrAuthHandler.alertLogout() {
            UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
        }
        globalHandler.updateReadings()
        
        GlobalHandler.sharedInstance.servicesHandler.startLocationService()
        
        self.refreshController = UIRefreshControl()
        self.gridView.addSubview(self.refreshController!)
        self.gridView.isScrollEnabled = true
        self.gridView.alwaysBounceVertical = true
        self.refreshController!.addTarget(self, action:#selector(ReadableIndexController.refreshLayout), for: UIControlEvents.valueChanged)
        
        self.navigationItem.title = "Speck Sensor"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        gridView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue" {
            // prepare for search segue
        } else if segue.identifier == "showSegue" {
            let addressShowController = segue.destination as! AddressShowController
            var indexPaths = gridView.indexPathsForSelectedItems!
            let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
            let indexPath = indexPaths[0]
            let reading = readingsHandler.adapterList[readingsHandler.headers[indexPath.section]]![indexPath.row]
            addressShowController.reading = reading
            gridView.deselectItem(at: indexPaths[0], animated: true)
        } else {
            NSLog("ERROR - bad segue name")
        }
    }
    
    
    // MARK: Collection View Delegate
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return GlobalHandler.sharedInstance.readingsHandler.adapterList.keys.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        return readingsHandler.adapterList[readingsHandler.headers[section]]!.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! ReadableIndexCell
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let readings = readingsHandler.adapterList[readingsHandler.headers[indexPath.section]]!
        if readings.count > indexPath.row {
            cell.populate(readings[indexPath.row])
        } else {
            NSLog("WARNING - tried to populate cell at indexPath=\(indexPath.row) but section count was \(readings.count)")
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MyViewHeader", for: indexPath) as! ReadableIndexHeader
            header.populate(GlobalHandler.sharedInstance.readingsHandler.headers[indexPath.section])
            reusableView = header
        }
        
        return reusableView!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/2.0-0.5, height: collectionView.bounds.size.width/2.0-1.0)
    }
    
}
