//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: Readable, Hashable {
    
    
    // MARK: Readable/Hashable implementation
    
    
    private let readableType = ReadableType.ADDRESS
    var hashValue: Int { return generateHashForReadable() }
    
    
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    
    
    func hasReadableValue() -> Bool {
        return self.closestFeed != nil
    }
    
    
    func getReadableValue() -> Double {
        if self.hasReadableValue() {
            return self.closestFeed!.feedValue
        }
        NSLog("Failed to get Readable Value on SimpleAddress; returning 0.0")
        return 0.0
    }
    
    
    func getName() -> String {
        return self.name
    }
    
    
    // MARK: class-specific definitions
    
    
    var _id: NSManagedObjectID?
    var positionId: Int?
    var name: String
    var zipcode: String
    var location: Location
    var isCurrentLocation: Bool
    var closestFeed: Feed?
    var feeds: Array<Feed>
    let uid = 1
    
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        closestFeed = nil
        feeds = []
        isCurrentLocation = false
    }
    
    
    func requestUpdateFeeds() {
        NSLog("Called requestUpdateFeeds() on Address=\(self.name)")
        self.feeds.removeAll(keepCapacity: false)
        self.closestFeed = nil
        // the past 24 hours
        let maxTime = NSDate().timeIntervalSince1970 - Constants.READINGS_MAX_TIME_RANGE
        
        func completionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
            } else {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                
                self.feeds.appendContentsOf(JsonParser.populateFeedsFromJson(data!, maxTime: maxTime))
                NSLog("populated \(feeds.count) feeds")
                if feeds.count > 0 {
                    NSLog("Found non-zero feeds")
                    if let closestFeed = MapGeometry.getClosestFeedToAddress(self, feeds: feeds) {
                        NSLog("closestFeed EXISTS!")
                        self.closestFeed = closestFeed
                        EsdrFeedsHandler.sharedInstance.requestChannelReading(closestFeed, channel: closestFeed.channels[0])
                    } else {
                        NSLog("But... closestFeed DNE?")
                    }
                }
            }
            NSLog("Finished completionHandler in requestUpdateFeeds()")
        }
        EsdrFeedsHandler.sharedInstance.requestFeeds(self.location, withinSeconds: maxTime, completionHandler: completionHandler)
    }
    
}

// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}