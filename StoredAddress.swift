//
//  StoredAddress.swift
//  AirPrototype
//
//  Created by mtasota on 8/25/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class StoredAddress: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var zipcode: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var position_id: Int

}
