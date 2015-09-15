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

class ReadableIndexController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var gridView: UICollectionView!
    // TODO configure to use hashmap
    var addressList = Array<SimpleAddress>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addressList = GlobalHandler.sharedInstance.requestAddressesForDisplay()
        
        DatabaseHelper.loadFromDb()
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.readableIndexListView = self.gridView
        globalHandler.updateReadings()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        NSLog("AddressListController: viewWillAppear")
        // reload our data
        // TODO configure to use hashmap
        addressList = GlobalHandler.sharedInstance.requestAddressesForDisplay()
        gridView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchSegue" {
            NSLog("running search segue")
        } else if segue.identifier == "showSegue" {
            NSLog("running show segue")
            var addressShowController = segue.destinationViewController as! AddressShowController
            var indexPaths = gridView.indexPathsForSelectedItems() as! Array<NSIndexPath>
            addressShowController.address = addressList[indexPaths[0].row]
            gridView.deselectItemAtIndexPath(indexPaths[0], animated: true)
        } else if segue.identifier == "settingsSegue" {
            NSLog("running settings segue")
        } else {
            NSLog("ERROR - bad segue name")
        }
    }
    
    
    // MARK: Collection View Delegate
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // TODO configure to use hashmap
        return 2
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO configure to use hashmap
        return addressList.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //        return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! ReadableIndexCell
        // TODO configure to use hashmap
        cell.populate(addressList[indexPath.row])
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            var header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MyViewHeader", forIndexPath: indexPath) as! ReadableIndexHeader
            // TODO configure to use hashmap
            header.populate(indexPath.section)
            reusableView = header
        }
        
        return reusableView!
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width/2.0-0.5, collectionView.bounds.size.width/2.0-1.0)
    }
    
    
    func removeAddress(address: SimpleAddress) {
        NSLog("To be removed")
        GlobalHandler.sharedInstance.headerReadingsHashMap.removeReading(address)
        addressList = GlobalHandler.sharedInstance.requestAddressesForDisplay()
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        DatabaseHelper.deleteAddressFromDb(address)
        gridView.reloadData()
    }
    
}