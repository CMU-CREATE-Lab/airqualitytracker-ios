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
    
    
    static func loadFromDb() {
        AddressDbHelper.loadAddressesFromDb()
        SpeckDbHelper.loadSpecksFromDb()
    }
    
}