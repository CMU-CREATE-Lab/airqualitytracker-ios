//
//  WuJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class WuJsonParser {
    
    
    static func parseAddressesFromJson(data: NSDictionary) -> Array<SimpleAddress> {
        var result = Array<SimpleAddress>()
        let addresses = data.valueForKey("RESULTS") as! Array<NSDictionary>
        for address in addresses {
            let resultAddress = SimpleAddress()
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