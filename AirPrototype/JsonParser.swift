//
//  JsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 7/22/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class JsonParser {
    
    
//    static func populateFeedsFromJson(feeds, response, maxTime)
//    static func populateAllFeedsFromJson(feeds, response)
//    static func parseFeedFromJson(row, maxTime)
//    static func parseChannelFromJson(channelName, feed, entry)
    
    
    static func parseAddressesFromJson(data: NSDictionary) -> Array<SimpleAddress> {
        var result = Array<SimpleAddress>()
        let addresses = data.valueForKey("RESULTS") as! Array<NSDictionary>
        for address in addresses {
            var resultAddress = SimpleAddress()
            if let latitude = address.valueForKey("lat") as? Double {
                resultAddress.latitude = latitude
            }
            if let longitude = address.valueForKey("lon") as? Double {
                resultAddress.longitude = longitude
            }
            if let name = address.valueForKey("name") as? String {
                resultAddress.name = name
            }
            result.append(resultAddress)
        }
        return result
    }
    
}