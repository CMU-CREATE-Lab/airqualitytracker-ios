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
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredAddress", in: managedObjectContext!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        // sort results
        request.sortDescriptors = [ NSSortDescriptor(key: SimpleAddressKeys.positionIdKey, ascending: true) ]
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
                    let name = match.value(forKey: SimpleAddressKeys.nameKey) as! String
                    let zipcode = match.value(forKey: SimpleAddressKeys.zipcodeKey) as! String
                    let latitude = match.value(forKey: SimpleAddressKeys.latitudeKey) as! Double
                    let longitude = match.value(forKey: SimpleAddressKeys.longitudeKey) as! Double
                    let positionId = match.value(forKey: SimpleAddressKeys.longitudeKey) as! Int
                    
                    let address = SimpleAddress()
                    address._id = match.objectID
                    address.name = name
                    address.zipcode = zipcode
                    address.location.latitude = latitude
                    address.location.longitude = longitude
                    address.positionId = positionId
                    GlobalHandler.sharedInstance.readingsHandler.addReading(address)
                }
            } else {
                NSLog("loadFromDb() Found 0 results")
            }
        }
    }
    
    
    static func addAddressToDb(_ address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "StoredAddress", in: managedObjectContext!)
        let storedAddress = StoredAddress(entity: entityDescription!, insertInto: managedObjectContext)
        var error: NSError?
        
        if let position = address.positionId {
            storedAddress.position_id = position
        } else if let position = GlobalHandler.sharedInstance.positionIdHelper.getAdressLastPosition() {
            address.positionId = position
        } else {
            storedAddress.position_id = 0
        }
        
        let insertValues: [String:AnyObject] = [
            SimpleAddressKeys.nameKey: address.name as AnyObject,
            SimpleAddressKeys.zipcodeKey: address.zipcode as AnyObject,
            SimpleAddressKeys.latitudeKey: address.location.latitude as AnyObject,
            SimpleAddressKeys.longitudeKey: address.location.longitude as AnyObject,
            SimpleAddressKeys.positionIdKey: address.positionId! as AnyObject
        ]
        storedAddress.setValuesForKeys(insertValues)
        
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
    
    
    static func updateAddressInDb(_ address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        var error: NSError?
        
        if let storedAddress = managedObjectContext?.object(with: address._id!) {
            if address.positionId == nil {
                if let position = GlobalHandler.sharedInstance.positionIdHelper.getAdressLastPosition() {
                    address.positionId = position
                } else {
                    address.positionId = 0
                }
            }
            
            let updateValues: [String:AnyObject] = [
                SimpleAddressKeys.nameKey: address.name as AnyObject,
                SimpleAddressKeys.zipcodeKey: address.zipcode as AnyObject,
                SimpleAddressKeys.latitudeKey: address.location.latitude as AnyObject,
                SimpleAddressKeys.longitudeKey: address.location.longitude as AnyObject,
                SimpleAddressKeys.positionIdKey: address.positionId! as AnyObject
            ]
            storedAddress.setValuesForKeys(updateValues)
            
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

    
    static func deleteAddressFromDb(_ address: SimpleAddress) {
        let managedObjectContext = GlobalHandler.sharedInstance.appDelegate.managedObjectContext
        
        if let storedAddress = managedObjectContext?.object(with: address._id!) {
            managedObjectContext?.delete(storedAddress)
            
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
