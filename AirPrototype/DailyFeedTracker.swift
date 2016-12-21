//
//  DailyFeedTracker.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class DailyFeedTracker {
    
    private var feed: Pm25Feed
    var values = Array<DayFeedValue>()
    private var to,from: Int
    // getters
    func getFeed() -> Pm25Feed { return feed }
    func getStartTime() -> Int { return from }
    
    
    init(feed: Pm25Feed, from: Int, to: Int) {
        self.feed = feed
        self.from = from
        self.to = to
    }
    
    
    func getDirtyDaysCount() -> Int {
        return getDaysCount(Constants.DIRTY_DAYS_VALUE_TYPE)
    }
    
    
    func getDaysCount(type: DayFeedValue.DaysValueType) -> Int {
        var size = 0;
        
        for feedValue in values {
            if Pm25AqiConverter.microgramsToAqi(feedValue.getCount(type)) > Constants.DIRTY_DAYS_AQI_THRESHOLD {
                size += 1;
            }
        }
        
        return size;
    }
    
}
