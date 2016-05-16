//
//  DailyFeedTracker.swift
//  AirPrototype
//
//  Created by Mike Tasota on 5/10/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class DailyFeedTracker {
    
    private var feed: Feed
    private var values = Array<DayFeedValue>()
    private var to,from: Int
    // getters
    func getFeed() -> Feed { return feed }
    func getValues() -> Array<DayFeedValue> { return values }
    func getStartTime() -> Int { return from }
    
    
    init(feed: Feed, from: Int, to: Int) {
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
            if AqiConverter.microgramsToAqi(feedValue.getCount(type)) > 50 {
                size += 1;
            }
        }
        
        return size;
    }
    
}
