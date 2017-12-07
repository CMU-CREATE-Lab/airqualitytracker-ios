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
    var feed: Pm25Feed?
    var minTimeSecs: Double
    var maxTimeSecs: Double
    var minValue: Double
    var maxValue: Double
    var instantcastValue: Double?
    var nowcastValue: Double?
    var nowCastCalculator: NowCastCalculator
    
    
    init() {
        name = ""
        minTimeSecs = 0
        maxTimeSecs = 0
        minValue = 0
        maxValue = 0
        nowCastCalculator = NowCastCalculator(hours: 12, weightType: NowCastCalculator.WeightType.piecewise)
    }
    
    
    func requestNowCast() {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        func response(_ data: [Int: [Double]]) {
            // construct array of values
            let array = nowCastCalculator.constructArrayFromHash(data, currentTime: timestamp)
            
            // find NowCast
            self.nowcastValue = nowCastCalculator.calculate(array)
            feed?.readablePm25Value = Pm25_NowCast(value: self.nowcastValue!, pm25Channel: self as! Pm25Channel)
            (feed as! AirQualityFeed).simpleAddress!.readablePm25Value = feed?.readablePm25Value
            
            // update adapters
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
        
        // request tiles from ESDR
        GlobalHandler.sharedInstance.esdrTilesHandler.requestTilesFromChannel(self, timestamp: timestamp, completionHandler: response)
    }
    
}
