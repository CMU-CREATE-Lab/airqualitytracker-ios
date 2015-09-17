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

class ReadableIndexController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var gridView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DatabaseHelper.loadFromDb()
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.readableIndexListView = self.gridView
        globalHandler.updateReadings()
        
        ServicesHandler.sharedInstance.startLocationService()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        NSLog("AddressListController: viewWillAppear")
        gridView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchSegue" {
            NSLog("running search segue")
        } else if segue.identifier == "showSegue" {
            NSLog("running show segue")
            var addressShowController = segue.destinationViewController as! AddressShowController
            var indexPaths = gridView.indexPathsForSelectedItems() as! Array<NSIndexPath>
            let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
            let indexPath = indexPaths[0]
            let reading = headerReadingsHashmap.hashMap[headerReadingsHashmap.headers[indexPath.section]]![indexPath.row]
            addressShowController.reading = reading
            gridView.deselectItemAtIndexPath(indexPaths[0], animated: true)
        } else if segue.identifier == "settingsSegue" {
            NSLog("running settings segue")
        } else {
            NSLog("ERROR - bad segue name")
        }
    }
    
    
    // MARK: Collection View Delegate
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return GlobalHandler.sharedInstance.headerReadingsHashMap.adapterList.keys.array.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
        return headerReadingsHashmap.adapterList[headerReadingsHashmap.headers[section]]!.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! ReadableIndexCell
        let headerReadingsHashmap = GlobalHandler.sharedInstance.headerReadingsHashMap
        let readings = headerReadingsHashmap.adapterList[headerReadingsHashmap.headers[indexPath.section]]!
        cell.populate(readings[indexPath.row])
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
            var header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MyViewHeader", forIndexPath: indexPath) as! ReadableIndexHeader
            header.populate(GlobalHandler.sharedInstance.headerReadingsHashMap.headers[indexPath.section])
            reusableView = header
        }
        
        return reusableView!
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width/2.0-0.5, collectionView.bounds.size.width/2.0-1.0)
    }
    
    
    // ASSERT: address is not current location
    func removeAddress(address: SimpleAddress) {
        NSLog("To be removed")
        GlobalHandler.sharedInstance.headerReadingsHashMap.removeReading(address)
        DatabaseHelper.deleteAddressFromDb(address)
        gridView.reloadData()
    }
    
}