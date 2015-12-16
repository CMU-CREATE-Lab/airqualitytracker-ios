//
//  SpeckDbHelper.swift
//  AirPrototype
//
//  Created by mtasota on 12/16/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SpeckDbHelper {
    
    struct SpeckKeys {
        static let nameKey = "name"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let positionIdKey = "position_id"
        static let deviceIdKey = "device_id"
        static let exposureKey = "exposure"
        static let feedIdKey = "feed_id"
        static let isMobileKey = "is_mobile"
        static let productIdKey = "product_id"
        static let apiKeyReadOnlyKey = "api_key_read_only"
    }
    
    
    static func loadSpecksFromDb() {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("StoredSpeck", inManagedObjectContext: managedObjectContext!)
        let request = NSFetchRequest()
        request.entity = entityDescription
        // sort results
        request.sortDescriptors = [ NSSortDescriptor(key: SpeckKeys.positionIdKey, ascending: true) ]
        var error: NSError?
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            objects = nil
        }
        
        if let results = objects {
            if results.count > 0 {
                for r in results {
                    let match = r as! NSManagedObject
                    let name = match.valueForKey(SpeckKeys.nameKey) as! String
                    let latitude = match.valueForKey(SpeckKeys.latitudeKey) as! NSNumber
                    let longitude = match.valueForKey(SpeckKeys.longitudeKey) as! NSNumber
                    let position_id = match.valueForKey(SpeckKeys.positionIdKey) as! Int
                    let device_id = match.valueForKey(SpeckKeys.deviceIdKey) as! Int
                    let exposure = match.valueForKey(SpeckKeys.exposureKey) as! String
                    let feed_id = match.valueForKey(SpeckKeys.feedIdKey) as! Int
                    let is_mobile = match.valueForKey(SpeckKeys.isMobileKey) as! Bool
                    let product_id = match.valueForKey(SpeckKeys.productIdKey) as! Int
                    
                    let feed = Feed()
                    feed.name = name
                    feed.location = Location(latitude: Double(latitude), longitude: Double(longitude))
                    feed.exposure = exposure
                    feed.feed_id = feed_id
                    feed.isMobile = is_mobile
                    feed.productId = product_id
                    
                    let speck = Speck(feed: feed, deviceId: device_id)
                    speck.positionId = position_id
                    speck._id = match.objectID
                    
                    if let apiKeyReadOnly = match.valueForKey(SpeckKeys.apiKeyReadOnlyKey) as? String {
                        if apiKeyReadOnly == "" {
                            deleteSpeckFromDb(speck)
                        } else {
                            speck.apiKeyReadOnly = apiKeyReadOnly
                            GlobalHandler.sharedInstance.headerReadingsHashMap.addReading(speck)
                            HttpRequestHandler.sharedInstance.requestChannelsForSpeck(speck)
                        }
                    } else {
                        deleteSpeckFromDb(speck)
                    }
                }
            } else {
                NSLog("loadFromDb() Found 0 results")
            }
        }
    }
    
    
    static func addSpeckToDb(speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("StoredSpeck", inManagedObjectContext: managedObjectContext!)
        let storedSpeck = StoredSpeck(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        var error: NSError?
        
        if let position = speck.positionId {
            storedSpeck.position_id = position
        } else if let position = SettingsHandler.sharedInstance.getSpeckLastPosition() {
            speck.positionId = position
        } else {
            storedSpeck.position_id = 0
        }
        
        let insertValues: [String:AnyObject] = [
            SpeckKeys.nameKey: speck.name,
            SpeckKeys.latitudeKey: speck.location.latitude,
            SpeckKeys.longitudeKey: speck.location.longitude,
            SpeckKeys.positionIdKey: speck.positionId!,
            SpeckKeys.deviceIdKey: speck.deviceId,
            SpeckKeys.exposureKey: speck.exposure,
            SpeckKeys.feedIdKey: speck.feed_id,
            SpeckKeys.isMobileKey: speck.isMobile,
            SpeckKeys.productIdKey: speck.productId,
            SpeckKeys.apiKeyReadOnlyKey: speck.apiKeyReadOnly!
        ]
        storedSpeck.setValuesForKeysWithDictionary(insertValues)
        
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("Error in addSpeckToDb")
        } else {
            speck._id = storedSpeck.objectID
            NSLog("Saved speck._id=\(speck._id?.description); saved objectID=\(storedSpeck.objectID.description)")
        }
    }
    
    
    static func updateSpeckInDb(speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        var error: NSError?
        
        if let storedSpeck = managedObjectContext?.objectWithID(speck._id!) {
            if speck.positionId == nil {
                if let position = SettingsHandler.sharedInstance.getSpeckLastPosition() {
                    speck.positionId = position
                } else {
                    speck.positionId = 0
                }
            }
            
            let insertValues: [String:AnyObject] = [
                SpeckKeys.nameKey: speck.name,
                SpeckKeys.latitudeKey: speck.location.latitude,
                SpeckKeys.longitudeKey: speck.location.longitude,
                SpeckKeys.positionIdKey: speck.positionId!,
                SpeckKeys.deviceIdKey: speck.deviceId,
                SpeckKeys.exposureKey: speck.exposure,
                SpeckKeys.feedIdKey: speck.feed_id,
                SpeckKeys.isMobileKey: speck.isMobile,
                SpeckKeys.productIdKey: speck.productId
            ]
            storedSpeck.setValuesForKeysWithDictionary(insertValues)
            
            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                NSLog("Error in updateSpeckInDb")
            } else {
                speck._id = storedSpeck.objectID
                NSLog("Saved speck._id=\(speck._id?.description); saved objectID=\(storedSpeck.objectID.description)")
            }
            
        }
    }
    
    
    static func deleteSpeckFromDb(speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        if let storedSpeck = managedObjectContext?.objectWithID(speck._id!) {
            managedObjectContext?.deleteObject(storedSpeck)
            
            var error: NSError?
            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                NSLog("received error in deleteAddressFromDb")
            } else {
                NSLog("Deleted address._id=\(speck._id?.description)")
            }
        }
    }
    
}