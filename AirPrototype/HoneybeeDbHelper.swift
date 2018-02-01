//
//  HoneybeeDbHelper.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 1/11/18.
//  Copyright © 2018 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class HoneybeeDbHelper {
    
    struct HoneybeeKeys {
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
        static let measureSmall = "measure_small"
    }
    
    
    static func loadHoneybeesFromDb() {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredHoneybee", in: managedObjectContext!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        // sort results
        request.sortDescriptors = [ NSSortDescriptor(key: HoneybeeKeys.positionIdKey, ascending: true) ]
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
                    let name = match.value(forKey: HoneybeeKeys.nameKey) as! String
                    let latitude = match.value(forKey: HoneybeeKeys.latitudeKey) as! NSNumber
                    let longitude = match.value(forKey: HoneybeeKeys.longitudeKey) as! NSNumber
                    let position_id = match.value(forKey: HoneybeeKeys.positionIdKey) as! Int
                    let device_id = match.value(forKey: HoneybeeKeys.deviceIdKey) as! Int
                    let exposure = match.value(forKey: HoneybeeKeys.exposureKey) as! String
                    let feed_id = match.value(forKey: HoneybeeKeys.feedIdKey) as! Int
                    let is_mobile = match.value(forKey: HoneybeeKeys.isMobileKey) as! Bool
                    let product_id = match.value(forKey: HoneybeeKeys.productIdKey) as! Int
                    let measure_small = match.value(forKey: HoneybeeKeys.measureSmall) as! Bool
                    
                    let honeybee = Honeybee(deviceId: device_id)
                    honeybee.positionId = position_id
                    honeybee._id = match.objectID
                    honeybee.feed_id = feed_id
                    honeybee.name = name
                    honeybee.location = Location(latitude: Double(latitude), longitude: Double(longitude))
                    honeybee.exposure = exposure
                    honeybee.isMobile = is_mobile
                    honeybee.productId = product_id
                    honeybee.measureSmall = measure_small

                    if let apiKeyReadOnly = match.value(forKey: HoneybeeKeys.apiKeyReadOnlyKey) as? String {
                        if apiKeyReadOnly == "" {
                            deleteHoneybeeFromDb(honeybee)
                        } else {
                            honeybee.apiKeyReadOnly = apiKeyReadOnly
                            GlobalHandler.sharedInstance.readingsHandler.addReading(honeybee)
                            GlobalHandler.sharedInstance.esdrHoneybeesHandler.requestChannelsForHoneybee(honeybee)
                        }
                    } else {
                        deleteHoneybeeFromDb(honeybee)
                    }
                }
            } else {
                NSLog("loadFromDb() Found 0 results")
            }
        }
    }
    
    
    static func addHoneybeeToDb(_ honeybee: Honeybee) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredHoneybee", in: managedObjectContext!)
        let storedHoneybee = StoredHoneybee(entity: entityDescription!, insertInto: managedObjectContext)
        var error: NSError?

        if let position = honeybee.positionId {
            storedHoneybee.position_id = position
        } else if let position = GlobalHandler.sharedInstance.positionIdHelper.getHoneybeeLastPosition() {
            honeybee.positionId = position
        } else {
            storedHoneybee.position_id = 0
        }

        let insertValues: [String:AnyObject] = [
            HoneybeeKeys.nameKey: honeybee.name as AnyObject,
            HoneybeeKeys.latitudeKey: honeybee.location.latitude as AnyObject,
            HoneybeeKeys.longitudeKey: honeybee.location.longitude as AnyObject,
            HoneybeeKeys.positionIdKey: honeybee.positionId! as AnyObject,
            HoneybeeKeys.deviceIdKey: honeybee.deviceId as AnyObject,
            HoneybeeKeys.exposureKey: honeybee.exposure as AnyObject,
            HoneybeeKeys.feedIdKey: honeybee.feed_id as AnyObject,
            HoneybeeKeys.isMobileKey: honeybee.isMobile as AnyObject,
            HoneybeeKeys.productIdKey: honeybee.productId as AnyObject,
            HoneybeeKeys.apiKeyReadOnlyKey: honeybee.apiKeyReadOnly! as AnyObject,
            HoneybeeKeys.measureSmall: honeybee.measureSmall as AnyObject
        ]
        storedHoneybee.setValuesForKeys(insertValues)

        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("Error in addHoneybeeToDb")
        } else {
            honeybee._id = storedHoneybee.objectID
            NSLog("Saved honeybee._id=\(honeybee._id?.description); saved objectID=\(storedHoneybee.objectID.description)")
        }
    }
    
    
    static func updateHoneybeeInDb(_ honeybee: Honeybee) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        var error: NSError?

        if let storedHoneybee = managedObjectContext?.object(with: honeybee._id!) {
            if honeybee.positionId == nil {
                if let position = GlobalHandler.sharedInstance.positionIdHelper.getHoneybeeLastPosition() {
                    honeybee.positionId = position
                } else {
                    honeybee.positionId = 0
                }
            }

            let insertValues: [String:AnyObject] = [
                HoneybeeKeys.nameKey: honeybee.name as AnyObject,
                HoneybeeKeys.latitudeKey: honeybee.location.latitude as AnyObject,
                HoneybeeKeys.longitudeKey: honeybee.location.longitude as AnyObject,
                HoneybeeKeys.positionIdKey: honeybee.positionId! as AnyObject,
                HoneybeeKeys.deviceIdKey: honeybee.deviceId as AnyObject,
                HoneybeeKeys.exposureKey: honeybee.exposure as AnyObject,
                HoneybeeKeys.feedIdKey: honeybee.feed_id as AnyObject,
                HoneybeeKeys.isMobileKey: honeybee.isMobile as AnyObject,
                HoneybeeKeys.productIdKey: honeybee.productId as AnyObject,
                HoneybeeKeys.apiKeyReadOnlyKey: honeybee.apiKeyReadOnly! as AnyObject,
                HoneybeeKeys.measureSmall: honeybee.measureSmall as AnyObject
            ]
            storedHoneybee.setValuesForKeys(insertValues)

            do {
                try managedObjectContext?.save()
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                NSLog("Error in updateHoneybeeInDb")
            } else {
                honeybee._id = storedHoneybee.objectID
                NSLog("Saved honeybee._id=\(honeybee._id?.description); saved objectID=\(storedHoneybee.objectID.description)")
            }

        }
    }
    
    
    static func deleteHoneybeeFromDb(_ honeybee: Honeybee) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        if let id = honeybee._id {
            if let storedHoneybee = managedObjectContext?.object(with: id) {
                managedObjectContext?.delete(storedHoneybee)

                var error: NSError?
                do {
                    try managedObjectContext?.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    NSLog("received error in deleteHoneybeeFromDb")
                } else {
                    NSLog("Deleted address._id=\(honeybee._id?.description)")
                }
            }
        } else {
            NSLog("Ignoring delete honeybee without an ID")
        }
    }
    
    
    static func clearHoneybeesFromDb(_ honeybees: [Honeybee]) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext

        for honeybee in honeybees {
            if let id = honeybee._id {
                if let storedHoneybee = managedObjectContext?.object(with: id) {
                    managedObjectContext?.delete(storedHoneybee)
                }
            } else {
                NSLog("Ignoring delete honeybee without an ID")
            }
        }

        var error: NSError?
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("received error in clearHoneybeesFromDb")
        }
    }
    
}
