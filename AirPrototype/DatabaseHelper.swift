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
    }
    
    
    static func loadFromDb() {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        let entityDescription =
        NSEntityDescription.entityForName("StoredAddress",
            inManagedObjectContext: managedObjectContext!)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        
        var objects = managedObjectContext?.executeFetchRequest(request,
            error: &error)
        
        if let results = objects {
            
            if results.count > 0 {
                for r in results {
                    let match = r as! NSManagedObject
                    let name = match.valueForKey(SimpleAddressKeys.nameKey) as! String
                    let zipcode = match.valueForKey(SimpleAddressKeys.zipcodeKey) as! String
                    let latitude = match.valueForKey(SimpleAddressKeys.latitudeKey) as! Double
                    let longitude = match.valueForKey(SimpleAddressKeys.longitudeKey) as! Double
                    
                    NSLog("Retrieving result name=\(name), zip=\(zipcode), lat=\(latitude), long=\(longitude)")
                    let address = SimpleAddress()
                    address._id = match.objectID
                    address.name = name
                    address.zipcode = zipcode
                    address.latitude = latitude
                    address.longitude = longitude
                    GlobalHandler.sharedInstance.addressFeedsHashMap.addAddress(address)
                }
            } else {
                NSLog("loadFromDb() Found 0 results")
            }
        }
    }
    
    
    static func addAddressToDb(address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        let entityDescription =
        NSEntityDescription.entityForName("StoredAddress",
            inManagedObjectContext: managedObjectContext!)
        
        let storedAddress = StoredAddress(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        storedAddress.name = address.name
        storedAddress.zipcode = address.zipcode
        storedAddress.latitude = address.latitude
        storedAddress.longitude = address.longitude
        
        var error: NSError?
        
        managedObjectContext?.save(&error)
        
        if let err = error {
            NSLog("Error in addAddressToDb")
        } else {
            address._id = storedAddress.objectID
            NSLog("Saved address._id=\(address._id?.description); saved objectID=\(storedAddress.objectID.description)")
        }
    }
    
    
    static func deleteAddressFromDb(address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        if let storedAddress = managedObjectContext?.objectWithID(address._id!) {
            managedObjectContext?.deleteObject(storedAddress)
            
            var error: NSError?
            managedObjectContext?.save(&error)
            if error != nil {
                NSLog("received error in deleteAddressFromDb")
            } else {
                NSLog("Deleted address._id=\(address._id?.description)")
            }
        }
    }
    
}