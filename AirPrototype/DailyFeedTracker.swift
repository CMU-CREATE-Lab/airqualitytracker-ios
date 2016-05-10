//
//  DailyFeedTracker.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class DailyFeedTracker {
    
    var feed: Feed
    var values = Array<DayFeedValue>()
    
    
    init(feed: Feed) {
        self.feed = feed
    }
    
}
