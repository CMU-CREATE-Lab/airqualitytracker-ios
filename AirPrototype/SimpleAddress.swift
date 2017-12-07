//
//  SimpleAddress.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreData

class SimpleAddress: AirNowReadable, Pm25Readable, OzoneReadable, Hashable {
    
    var readablePm25Value: AqiReadableValue?
    var readableOzoneValue: AqiReadableValue?
    var hashValue: Int { return generateHashForReadable() }
    var location: Location
    var airNowObservations: [AirNowObservation]
    
    
    // MARK: class-specific definitions
    
    
    var _id: NSManagedObjectID?
    var positionId: Int?
    var name: String
    var zipcode: String
    var isCurrentLocation: Bool
    var feeds: Array<AirQualityFeed>
    let uid = 1
    var dailyFeedTracker: DailyFeedTracker?
    
    
    init() {
        name = ""
        zipcode = ""
        location = Location(latitude: 0, longitude: 0)
        feeds = []
        isCurrentLocation = false
        airNowObservations = []
    }
    
    
    func requestDailyFeedTracker(_ controller: AddressShowController) {
        let to = Int(Date().timeIntervalSince1970)
        let from = to - (86400 * 365)
        if hasReadablePm25Value() {
            let closestFeed = getReadablePm25Value().channel.feed
            if let tracker = dailyFeedTracker {
                // check that this tracker is at least within the last 24 hours (otherwise it needs updated)
                if (to - tracker.getStartTime()) <= Constants.TWENTY_FOUR_HOURS {
                    let numberDirtyDays = tracker.getDirtyDaysCount()
                    let text = "\(numberDirtyDays) dirty day\( (numberDirtyDays == 1 ? "" : "s") ) in the past year"
                    controller.feedTrackerResponse(text)
                    return;
                }
            }
            
            func httpResponse(_ url: URL?, response: URLResponse?, error: Error?) -> Void {
                let jsonString = try! NSString.init(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
                let formattedString = EsdrJsonParser.formatSafeJson(jsonString)
                let tempData = formattedString.data(using: String.Encoding.utf8.rawValue)
                let data = (try! JSONSerialization.jsonObject(with: tempData!, options: [])) as? NSDictionary
                
                self.dailyFeedTracker = EsdrJsonParser.parseDailyFeedTracker(closestFeed!, from: from, to: to, dataEntry: data!)
                let numberDirtyDays = dailyFeedTracker!.getDirtyDaysCount()
                let text = "\(numberDirtyDays) dirty day\( (numberDirtyDays == 1 ? "" : "s") ) in the past year"
                controller.feedTrackerResponse(text)
            }
            GlobalHandler.sharedInstance.esdrTilesHandler.requestFeedAverages(closestFeed!, from: from, to: to, response: httpResponse)
        } else {
            NSLog("requestDailyFeedTracker failed (ReadablePm25Value DNE)")
        }
    }
    
    
    func requestReadablePm25Reading() {
        let maxTime = Date().timeIntervalSince1970 - Constants.READINGS_MAX_TIME_RANGE
        
        func completionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                
                self.feeds = EsdrJsonParser.populateFeedsFromJson(data!, simpleAddress: self, maxTime: maxTime)
                if (feeds.count > 0) {
                    let closestFeed = MapGeometry.getClosestFeedWithPmToAddress(self, feeds: self.feeds)
                    if closestFeed != nil {
                        closestFeed!.simpleAddress = self
                        if Constants.DEFAULT_ADDRESS_PM25_READABLE_VALUE_TYPE == ReadableValueType.nowcast {
                            closestFeed!.getPm25Channels().first!.requestNowCast()
                        } else if Constants.DEFAULT_ADDRESS_PM25_READABLE_VALUE_TYPE == ReadableValueType.instantcast {
                            GlobalHandler.sharedInstance.esdrFeedsHandler.requestChannelReading(nil, feedApiKey: nil, feed: closestFeed!, channel: closestFeed!.getPm25Channels().first!, maxTime: maxTime)
                        }
                    }
                }
            } else {
                NSLog("unsuccessful response")
            }
        }
        
        GlobalHandler.sharedInstance.esdrFeedsHandler.requestFeeds(self.location, withinSeconds: maxTime, completionHandler: completionHandler)
    }
    
    
    func requestReadableOzoneReading() {
        let maxTime = Date().timeIntervalSince1970 - Constants.READINGS_MAX_TIME_RANGE
        
        func completionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                
                self.feeds = EsdrJsonParser.populateFeedsFromJson(data!, simpleAddress: self, maxTime: maxTime)
                if (feeds.count > 0) {
                    let closestFeed = MapGeometry.getClosestFeedWithOzoneToAddress(self, feeds: self.feeds)
                    if closestFeed != nil {
                        closestFeed!.simpleAddress = self
                        if Constants.DEFAULT_ADDRESS_OZONE_READABLE_VALUE_TYPE == ReadableValueType.nowcast {
                            closestFeed!.getOzoneChannels().first!.requestNowCast()
                        } else if Constants.DEFAULT_ADDRESS_OZONE_READABLE_VALUE_TYPE == ReadableValueType.instantcast {
                            GlobalHandler.sharedInstance.esdrFeedsHandler.requestChannelReading(nil, feedApiKey: nil, feed: closestFeed!, channel: closestFeed!.getOzoneChannels().first!, maxTime: maxTime)
                        }
                    }
                }
            } else {
                NSLog("unsuccessful response")
            }
        }
        
        GlobalHandler.sharedInstance.esdrFeedsHandler.requestFeeds(self.location, withinSeconds: maxTime, completionHandler: completionHandler)
    }
    
    
    // Pm25Readable implementation
    
    
    func getPm25Channels() -> Array<Pm25Channel> {
        var result = Array<Pm25Channel>()
        
        for feed in self.feeds {
            result.append(contentsOf: feed.getPm25Channels())
        }
        
        return result
    }
    
    
    func hasReadablePm25Value() -> Bool {
        return (readablePm25Value != nil)
    }
    
    
    func getReadablePm25Value() -> AqiReadableValue {
        return readablePm25Value!
    }

    
    // OzoneReadable implementation
    
    
    func getOzoneChannels() -> Array<OzoneChannel> {
        var result = Array<OzoneChannel>()
        
        for feed in self.feeds {
            result.append(contentsOf: feed.getOzoneChannels())
        }
        
        return result
    }
    
    
    func hasReadableOzoneValue() -> Bool {
        return (readableOzoneValue != nil)
    }
    
    
    func getReadableOzoneValue() -> AqiReadableValue {
        return readableOzoneValue!
    }
    
    
    // Readable Implementation
    
    
    fileprivate func generateReadableValues() -> Array<ReadableValue> {
        var result = Array<ReadableValue>()
        if (hasReadablePm25Value()) {
            result.append(self.readablePm25Value!)
        }
        if (hasReadableOzoneValue()) {
            result.append(self.readableOzoneValue!)
        }
        return result
    }
    
    
    func hasReadableValue() -> Bool {
        return (generateReadableValues().count > 0)
    }
    
    
    func getReadableValues() -> Array<ReadableValue> {
        return generateReadableValues()
    }
    
    
    func getName() -> String {
        return self.name
    }
    
}

// conforms to Equatable protocol
func == (lhs: SimpleAddress, rhs: SimpleAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
