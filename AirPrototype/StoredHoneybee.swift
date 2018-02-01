//
//  StoredHoneybee.swift
//  SpeckSensor
//
//  Created by Mike Tasota on 1/11/18.
//  Copyright © 2018 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class StoredHoneybee: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var position_id: Int
    @NSManaged var device_id: Int
    @NSManaged var exposure: String
    @NSManaged var feed_id: Int
    @NSManaged var is_mobile: Bool
    @NSManaged var product_id: Int
    @NSManaged var api_key_read_only: String
    @NSManaged var measure_small: Bool
    
}
