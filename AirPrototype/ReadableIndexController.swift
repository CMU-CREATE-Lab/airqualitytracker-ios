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
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        longPressActive = false
        if buttonIndex > 0 {
            self.navigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecretMenu"), animated: true)
        }
    }
    
    
    func refreshLayout() {
        GlobalHandler.sharedInstance.updateReadings()
        self.refreshController!.endRefreshing()
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func longPressOccurred(sender: UILongPressGestureRecognizer) {
        if !longPressActive {
            longPressActive = true
            let dialog = UIAlertView.init(title: "DEBUG", message: "View Debug Screen?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            dialog.show()
        }
    }

    
    @IBAction func menuClicked(sender: UIBarButtonItem) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsPopup") as! SettingsController
        // NOTE: preferred content size is controlled on SettingsController's viewDidLoad() function
        controller.parentNavigationController = self.navigationController
        controller.modalPresentationStyle = UIModalPresentationStyle.Popover
        if let popover = controller.popoverPresentationController {
            popover.delegate = self
            popover.barButtonItem = sender
            popover.permittedArrowDirections = .Any
            self.presentViewController(controller, animated: true, completion: nil)
            controller.view.sizeToFit()
        }
    }
    
    
    // MARK: UIView Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NOTICE: in Swiftland, we cannot call these functions
        // within GlobalHandler (since we cannot pass the reference 
        // until after init). Instead, we load from the DB here.
        AddressDbHelper.loadAddressesFromDb()
        SpeckDbHelper.loadSpecksFromDb()
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.readableIndexListView = self.gridView
        globalHandler.updateReadings()
        
        GlobalHandler.sharedInstance.servicesHandler.startLocationService()
        
        self.refreshController = UIRefreshControl()
        self.gridView.addSubview(self.refreshController!)
        self.gridView.scrollEnabled = true
        self.gridView.alwaysBounceVertical = true
        self.refreshController!.addTarget(self, action:"refreshLayout", forControlEvents: UIControlEvents.ValueChanged)
        
        self.navigationItem.title = "Speck Sensor"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        gridView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchSegue" {
            // prepare for search segue
        } else if segue.identifier == "showSegue" {
            let addressShowController = segue.destinationViewController as! AddressShowController
            var indexPaths = gridView.indexPathsForSelectedItems()!
            let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
            let indexPath = indexPaths[0]
            let reading = readingsHandler.adapterList[readingsHandler.headers[indexPath.section]]![indexPath.row]
            addressShowController.reading = reading
            gridView.deselectItemAtIndexPath(indexPaths[0], animated: true)
        } else {
            NSLog("ERROR - bad segue name")
        }
    }
    
    
    // MARK: Collection View Delegate
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return GlobalHandler.sharedInstance.readingsHandler.adapterList.keys.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        return readingsHandler.adapterList[readingsHandler.headers[section]]!.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! ReadableIndexCell
        let readingsHandler = GlobalHandler.sharedInstance.readingsHandler
        let readings = readingsHandler.adapterList[readingsHandler.headers[indexPath.section]]!
        // TODO sometimes we get out of index here?
        cell.populate(readings[indexPath.row])
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MyViewHeader", forIndexPath: indexPath) as! ReadableIndexHeader
            header.populate(GlobalHandler.sharedInstance.readingsHandler.headers[indexPath.section])
            reusableView = header
        }
        
        return reusableView!
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width/2.0-0.5, collectionView.bounds.size.width/2.0-1.0)
    }
    
}