//
//  StoredSpeck.swift
//  AirPrototype
//
//  Created by mtasota on 10/26/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class StoredSpeck: NSManagedObject {
    
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
    
}
