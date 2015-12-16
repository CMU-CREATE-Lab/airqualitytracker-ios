//
//  AddressDbHelper.swift
//  AirPrototype
//
//  Created by mtasota on 12/16/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class AddressDbHelper {
    
    struct SimpleAddressKeys {
        static let nameKey = "name"
        static let zipcodeKey = "zipcode"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let positionIdKey = "position_id"
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
    
}
