//
//  WuJsonParser.swift
//  AirPrototype
//
//  Created by mtasota on 2/11/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class WuJsonParser {
    
    
    static func parseAddressesFromJson(_ data: NSDictionary) -> Array<SimpleAddress> {
        var result = Array<SimpleAddress>()
        let addresses = data.value(forKey: "RESULTS") as! Array<NSDictionary>
        for address in addresses {
            let resultAddress = SimpleAddress()
            if let latitude = address.value(forKey: "lat") as? String {
                resultAddress.location.latitude = NSString(string: latitude).doubleValue
            }
            if let longitude = address.value(forKey: "lon") as? String {
                resultAddress.location.longitude = NSString(string: longitude).doubleValue
            }
            if let name = address.value(forKey: "name") as? String {
                resultAddress.name = name
            }
            // TODO string needs formatted
            if let zip = address.value(forKey: "zmw") as? String {
                resultAddress.zipcode = zip
            }
            result.append(resultAddress)
        }
        return result
    }
    
}
