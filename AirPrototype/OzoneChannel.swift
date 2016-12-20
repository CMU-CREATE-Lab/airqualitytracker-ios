//
//  OzoneChannel.swift
//  AirPrototype
//
//  Created by Mike Tasota on 12/14/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class OzoneChannel: Channel {
    
    
    override init() {
        super.init()
        nowCastCalculator = NowCastCalculator(hours: 8, weightType: NowCastCalculator.WeightType.RATIO)
    }
    
    
    override func requestNowCast() {
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        func response(data: [Int: [Double]]) {
            // construct array of values
            let array = nowCastCalculator.constructArrayFromHash(data, currentTime: timestamp)
            
            // find NowCast
            self.nowcastValue = nowCastCalculator.calculate(array)
            (feed as! AirQualityFeed).readableOzoneValue = Ozone_NowCast(value: self.nowcastValue!, ozoneChannel: self )
            (feed as! AirQualityFeed).simpleAddress!.readableOzoneValue = (feed as! AirQualityFeed).readableOzoneValue
            
            // update adapters
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
        
        // request tiles from ESDR
        GlobalHandler.sharedInstance.esdrTilesHandler.requestTilesFromChannel(self, timestamp: timestamp, completionHandler: response)
    }
    
}
