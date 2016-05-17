//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: AirNowReadable, Hashable {
    
    
    // MARK: AirNowReadable/Hashable implementation
    
    
    private let readableType = ReadableType.ADDRESS
    var hashValue: Int { return generateHashForReadable() }
    var location: Location
    var airNowObservations: [AirNowObservation]
    
    
    func getReadableType() -> ReadableType {
        return self.readableType
    }
    
    
    func hasReadableValue() -> Bool {
        if let feed = self.closestFeed {
            return feed.hasReadableValue()
        }
        return false
    }
    
    
    func getReadableValue() -> Double {
        if self.hasReadableValue() {
            return self.closestFeed!.getReadableValue()
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
    var isCurrentLocation: Bool
    var closestFeed: Feed?
    var feeds: Array<Feed>
    let uid = 1
    var dailyFeedTracker: DailyFeedTracker?
    
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        closestFeed = nil
        feeds = []
        isCurrentLocation = false
        airNowObservations = []
    }
    
    
    func requestDailyFeedTracker(controller: AddressShowController) {
        let to = Int(NSDate().timeIntervalSince1970)
        let from = to - (86400 * 365)
        if closestFeed == nil {
            NSLog("requestDailyFeedTracker failed (closestFeed is null)")
            return;
        }
        if let tracker = dailyFeedTracker {
            // check that this tracker is at least within the last 24 hours (otherwise it needs updated)
            if (to - tracker.getStartTime()) <= Constants.TWENTY_FOUR_HOURS {
                let numberDirtyDays = tracker.getDirtyDaysCount()
                let text = "\(numberDirtyDays) dirty day\( (numberDirtyDays == 1 ? "" : "s") ) in the past year"
                controller.feedTrackerResponse(text)
                return;
            }
        }
        
        func httpResponse(url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void {
            let jsonString = try! NSString.init(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
            let formattedString = EsdrJsonParser.formatSafeJson(jsonString)
            let tempData = formattedString.dataUsingEncoding(NSUTF8StringEncoding)
            let data = (try! NSJSONSerialization.JSONObjectWithData(tempData!, options: [])) as? NSDictionary
            
            self.dailyFeedTracker = EsdrJsonParser.parseDailyFeedTracker(closestFeed!, from: from, to: to, dataEntry: data!)
            let numberDirtyDays = dailyFeedTracker!.getDirtyDaysCount()
            let text = "\(numberDirtyDays) dirty day\( (numberDirtyDays == 1 ? "" : "s") ) in the past year"
            controller.feedTrackerResponse(text)
        }
        GlobalHandler.sharedInstance.esdrTilesHandler.requestFeedAverages(closestFeed!, from: from, to: to, response: httpResponse)
    }
    
}

// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}