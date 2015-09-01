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
//            let s1 = NSString(string: address.valueForKey("lat") as! String).doubleValue
//            let s2 = NSString(string: address.valueForKey("lon") as! String).doubleValue
//            NSLog("parsed JSON: lat=\(s1.description),lon=\(s2.description)")
            
            if let latitude = address.valueForKey("lat") as? String {
                resultAddress.location.latitude = NSString(string: latitude).doubleValue
            }
            if let longitude = address.valueForKey("lon") as? String {
                resultAddress.location.longitude = NSString(string: longitude).doubleValue
            }
            if let name = address.valueForKey("name") as? String {
                resultAddress.name = name
            }
            // TODO string needs formatted
            if let zip = address.valueForKey("zmw") as? String {
                resultAddress.zipcode = zip
            }
            result.append(resultAddress)
        }
        return result
    }
    
}