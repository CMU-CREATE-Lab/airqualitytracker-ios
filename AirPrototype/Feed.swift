//
//  Feed.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

protocol Feed: Readable, Hashable {
    
    // class attributes
    var feed_id: Int { get set }
    var name: String { get set }
    var exposure: String { get set }
    var isMobile: Bool { get set }
    var location: Location { get set }
    var productId: Int { get set }
    var lastTime: Double { get set }
    
}


extension Feed {
    
    var hashValue: Int { return generateHashForReadable() }
    
    
    func getName() -> String {
        return self.name
    }
    
}
