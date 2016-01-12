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
        
        func response(data: [Int: [Double]]) {
            // construct array of values
            let array = NowCastCalculator.constructArrayFromHash(data)
            NSLog("Channel \(self.name) received array \(array)")
            
            // find NowCast
            let nowcast = NowCastCalculator.calculate(array)
            self.nowcastValue = nowcast
            NSLog("Channel \(self.name) nowcast value set to =\(nowcast)")
        }
        
        GlobalHandler.sharedInstance.esdrTilesHandler.requestTilesFromChannel(self, completionHandler: response)
    }
    
}
