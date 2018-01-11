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
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredSpeck", in: managedObjectContext!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        // sort results
        request.sortDescriptors = [ NSSortDescriptor(key: SpeckKeys.positionIdKey, ascending: true) ]
        var error: NSError?
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.fetch(request)
        } catch let error1 as NSError {
            error = error1
            objects = nil
        }
        
        if let results = objects {
            if results.count > 0 {
                for r in results {
                    let match = r as! NSManagedObject
                    let name = match.value(forKey: SpeckKeys.nameKey) as! String
                    let latitude = match.value(forKey: SpeckKeys.latitudeKey) as! NSNumber
                    let longitude = match.value(forKey: SpeckKeys.longitudeKey) as! NSNumber
                    let position_id = match.value(forKey: SpeckKeys.positionIdKey) as! Int
                    let device_id = match.value(forKey: SpeckKeys.deviceIdKey) as! Int
                    let exposure = match.value(forKey: SpeckKeys.exposureKey) as! String
                    let feed_id = match.value(forKey: SpeckKeys.feedIdKey) as! Int
                    let is_mobile = match.value(forKey: SpeckKeys.isMobileKey) as! Bool
                    let product_id = match.value(forKey: SpeckKeys.productIdKey) as! Int
                    
                    let feed = Pm25Feed()
                    feed.name = name
                    feed.location = Location(latitude: Double(latitude), longitude: Double(longitude))
                    feed.exposure = exposure
                    feed.feed_id = feed_id
                    feed.isMobile = is_mobile
                    feed.productId = product_id
                    
                    let speck = Speck(feed: feed, deviceId: device_id)
                    speck.positionId = position_id
                    speck._id = match.objectID
                    
                    if let apiKeyReadOnly = match.value(forKey: SpeckKeys.apiKeyReadOnlyKey) as? String {
                        if apiKeyReadOnly == "" {
                            deleteSpeckFromDb(speck)
                        } else {
                            speck.apiKeyReadOnly = apiKeyReadOnly
                            GlobalHandler.sharedInstance.readingsHandler.addReading(speck)
                            GlobalHandler.sharedInstance.esdrSpecksHandler.requestChannelsForSpeck(speck)
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
    
    
    static func addSpeckToDb(_ speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredSpeck", in: managedObjectContext!)
        let storedSpeck = StoredSpeck(entity: entityDescription!, insertInto: managedObjectContext)
        var error: NSError?
        
        if let position = speck.positionId {
            storedSpeck.position_id = position
        } else if let position = GlobalHandler.sharedInstance.positionIdHelper.getSpeckLastPosition() {
            speck.positionId = position
        } else {
            storedSpeck.position_id = 0
        }
        
        let insertValues: [String:AnyObject] = [
            SpeckKeys.nameKey: speck.name as AnyObject,
            SpeckKeys.latitudeKey: speck.location.latitude as AnyObject,
            SpeckKeys.longitudeKey: speck.location.longitude as AnyObject,
            SpeckKeys.positionIdKey: speck.positionId! as AnyObject,
            SpeckKeys.deviceIdKey: speck.deviceId as AnyObject,
            SpeckKeys.exposureKey: speck.exposure as AnyObject,
            SpeckKeys.feedIdKey: speck.feed_id as AnyObject,
            SpeckKeys.isMobileKey: speck.isMobile as AnyObject,
            SpeckKeys.productIdKey: speck.productId as AnyObject,
            SpeckKeys.apiKeyReadOnlyKey: speck.apiKeyReadOnly! as AnyObject
        ]
        storedSpeck.setValuesForKeys(insertValues)
        
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
    
    
    static func updateSpeckInDb(_ speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        var error: NSError?
        
        if let storedSpeck = managedObjectContext?.object(with: speck._id!) {
            if speck.positionId == nil {
                if let position = GlobalHandler.sharedInstance.positionIdHelper.getSpeckLastPosition() {
                    speck.positionId = position
                } else {
                    speck.positionId = 0
                }
            }
            
            let insertValues: [String:AnyObject] = [
                SpeckKeys.nameKey: speck.name as AnyObject,
                SpeckKeys.latitudeKey: speck.location.latitude as AnyObject,
                SpeckKeys.longitudeKey: speck.location.longitude as AnyObject,
                SpeckKeys.positionIdKey: speck.positionId! as AnyObject,
                SpeckKeys.deviceIdKey: speck.deviceId as AnyObject,
                SpeckKeys.exposureKey: speck.exposure as AnyObject,
                SpeckKeys.feedIdKey: speck.feed_id as AnyObject,
                SpeckKeys.isMobileKey: speck.isMobile as AnyObject,
                SpeckKeys.productIdKey: speck.productId as AnyObject,
                SpeckKeys.apiKeyReadOnlyKey: speck.apiKeyReadOnly! as AnyObject
            ]
            storedSpeck.setValuesForKeys(insertValues)
            
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
    
    
    static func deleteSpeckFromDb(_ speck: Speck) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        if let id = speck._id {
            if let storedSpeck = managedObjectContext?.object(with: id) {
                managedObjectContext?.delete(storedSpeck)
                
                var error: NSError?
                do {
                    try managedObjectContext?.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    NSLog("received error in deleteSpeckFromDb")
                } else {
                    NSLog("Deleted address._id=\(speck._id?.description)")
                }
            }
        } else {
            NSLog("Ignoring delete speck without an ID")
        }
    }
    
    
    static func clearSpecksFromDb(_ specks: [Speck]) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        for speck in specks {
            if let id = speck._id {
                if let storedSpeck = managedObjectContext?.object(with: id) {
                    managedObjectContext?.delete(storedSpeck)
                    
                }
            } else {
                NSLog("Ignoring delete speck without an ID")
            }
        }
        
        var error: NSError?
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("received error in clearSpecksFromDb")
        }
    }
    
}
