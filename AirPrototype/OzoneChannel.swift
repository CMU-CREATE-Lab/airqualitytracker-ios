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
            let ozoneNowcast = Ozone_NowCast(value: nowCastCalculator.calculate(array), ozoneChannel: self )
            let ozoneInstantcast = Ozone_InstantCast(value: nowCastCalculator.getMostRecent(data, currentTime: timestamp), ozoneChannel: self)
            
            // compare AQI values
            if ozoneInstantcast.getAqiValue() > ozoneNowcast.getAqiValue() {
                (feed as! AirQualityFeed).readableOzoneValue = ozoneInstantcast
                (feed as! AirQualityFeed).simpleAddress!.readableOzoneValue = ozoneInstantcast
            } else {
                (feed as! AirQualityFeed).readableOzoneValue = ozoneNowcast
                (feed as! AirQualityFeed).simpleAddress!.readableOzoneValue = ozoneNowcast
            }
            
            // update adapters
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
        
        // request tiles from ESDR
        GlobalHandler.sharedInstance.esdrTilesHandler.requestTilesFromChannel(self, timestamp: timestamp, completionHandler: response)
    }
    
}
