//
//  DatabaseHelper.swift
//  AirPrototype
//
//  Created by mtasota on 8/26/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class DatabaseHelper {
    
    struct SimpleAddressKeys {
        static let nameKey = "name"
        static let zipcodeKey = "zipcode"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let positionIdKey = "position_id"
    }
    
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
    
    
    static func loadFromDb() {
        loadAddressesFromDb()
        loadSpecksFromDb()
    }
    
    
    static func loadAddressesFromDb() {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("StoredAddress", inManagedObjectContext: managedObjectContext!)
        let request = NSFetchRequest()
        request.entity = entityDescription
        // sort results
        request.sortDescriptors = [ NSSortDescriptor(key: SimpleAddressKeys.positionIdKey, ascending: true) ]
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
                    let name = match.valueForKey(SimpleAddressKeys.nameKey) as! String
                    let zipcode = match.valueForKey(SimpleAddressKeys.zipcodeKey) as! String
                    let latitude = match.valueForKey(SimpleAddressKeys.latitudeKey) as! Double
                    let longitude = match.valueForKey(SimpleAddressKeys.longitudeKey) as! Double
                    let positionId = match.valueForKey(SimpleAddressKeys.longitudeKey) as! Int
                    
                    let address = SimpleAddress()
                    address._id = match.objectID
                    address.name = name
                    address.zipcode = zipcode
                    address.location.latitude = latitude
                    address.location.longitude = longitude
                    address.positionId = positionId
                    GlobalHandler.sharedInstance.headerReadingsHashMap.addReading(address)
                }
            } else {
                NSLog("loadFromDb() Found 0 results")
            }
        }
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
    
    
    static func addAddressToDb(address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("StoredAddress", inManagedObjectContext: managedObjectContext!)
        let storedAddress = StoredAddress(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        var error: NSError?
        
        if let position = address.positionId {
            storedAddress.position_id = position
        } else if let position = SettingsHandler.sharedInstance.getAdressLastPosition() {
            address.positionId = position
        } else {
            storedAddress.position_id = 0
        }
        
        let insertValues: [String:AnyObject] = [
            SimpleAddressKeys.nameKey: address.name,
            SimpleAddressKeys.zipcodeKey: address.zipcode,
            SimpleAddressKeys.latitudeKey: address.location.latitude,
            SimpleAddressKeys.longitudeKey: address.location.longitude,
            SimpleAddressKeys.positionIdKey: address.positionId!
        ]
        storedAddress.setValuesForKeysWithDictionary(insertValues)
        
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("Error in addAddressToDb")
        } else {
            address._id = storedAddress.objectID
            NSLog("Saved address._id=\(address._id?.description); saved objectID=\(storedAddress.objectID.description)")
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
    
    
    static func updateAddressInDb(address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        var error: NSError?
        
        if let storedAddress = managedObjectContext?.objectWithID(address._id!) {
            if address.positionId == nil {
                if let position = SettingsHandler.sharedInstance.getAdressLastPosition() {
                    address.positionId = position
                } else {
                    address.positionId = 0
                }
            }
            
            let updateValues: [String:AnyObject] = [
                SimpleAddressKeys.nameKey: address.name,
                SimpleAddressKeys.zipcodeKey: address.zipcode,
                SimpleAddressKeys.latitudeKey: address.location.latitude,
                SimpleAddressKeys.longitudeKey: address.location.longitude,
                SimpleAddressKeys.positionIdKey: address.positionId!
            ]
            storedAddress.setValuesForKeysWithDictionary(updateValues)
            
            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                NSLog("Error in updateAddressInDb")
            } else {
                address._id = storedAddress.objectID
                NSLog("Saved address._id=\(address._id?.description); saved objectID=\(storedAddress.objectID.description)")
            }
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
    
    
    static func deleteAddressFromDb(address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        if let storedAddress = managedObjectContext?.objectWithID(address._id!) {
            managedObjectContext?.deleteObject(storedAddress)
            
            var error: NSError?
            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                NSLog("received error in deleteAddressFromDb")
            } else {
                NSLog("Deleted address._id=\(address._id?.description)")
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