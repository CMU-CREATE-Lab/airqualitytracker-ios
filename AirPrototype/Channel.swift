//
//  Channel.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class Channel {
    
    var name: String
    var feed: Feed
    var minTimeSecs: Double
    var maxTimeSecs: Double
    var minValue: Double
    var maxValue: Double
    var nowcastValue: Double?
    
    
    init() {
        name = ""
        feed = Feed()
        minTimeSecs = 0
        maxTimeSecs = 0
        minValue = 0
        maxValue = 0
    }
    
    
    func requestNowCast() {
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        func response(data: [Int: [Double]]) {
            NSLog("--------")
            NSLog("Channel \(self.name) from Feed id=\(self.feed.feed_id)")
            NSLog("Data=\(data)")
            // construct array of values
            let array = NowCastCalculator.constructArrayFromHash(data, currentTime: timestamp)
            
            // find NowCast
            let nowcastUg = NowCastCalculator.calculate(array)
            let nowcast = Converter.microgramsToAqi( nowcastUg )
            self.nowcastValue = nowcast
            NSLog("Channel \(self.name) nowcast value set to =\(nowcast) from micrograms=\(nowcastUg)")
            
            NSLog("========")
        }
        
        // request tiles from ESDR
        GlobalHandler.sharedInstance.esdrTilesHandler.requestTilesFromChannel(self, timestamp: timestamp, completionHandler: response)
    }
    
}
