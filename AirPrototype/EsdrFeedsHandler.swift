//
//  EsdrFeedsHandler.swift
//  AirPrototype
//
//  Created by mtasota on 8/26/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class EsdrFeedsHandler {
    
    var appDelegate: AppDelegate
    
    
    init() {
        appDelegate = (UIApplication.shared.delegate! as? AppDelegate)!
    }
    
    
    func requestChannelReadingForHoneybee(feedApiKey: String?, honeybee: Honeybee, channel: Channel, maxTime: Double?) {
        let feedId = honeybee.feed_id.description
        let channelName = channel.name
        
        // handles http response
        func completionHandler(_ url: URL?, response: URLResponse?, error: Error?) -> Void {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                var temp:NSDictionary
                
                // NOTE (from Chris)
                // "don't expect mostRecentDataSample to always exist in the response for every channel,
                // and don't expect channelBounds.maxTimeSecs to always equal mostRecentDataSample.timeSecs"
                temp = data?.value(forKey: "data") as! NSDictionary
                temp = temp.value(forKey: "channels") as! NSDictionary
                temp = temp.value(forKey: channelName) as! NSDictionary
                temp = temp.value(forKey: "mostRecentDataSample") as! NSDictionary
                
                let resultValue = temp.value(forKey: "value") as? NSNumber
                let resultTime = temp.value(forKey: "timeSecs") as? NSNumber
                if resultValue != nil && resultTime != nil {
                    if maxTime == nil {
                        if (channel is LargeParticleChannel) {
                            honeybee.readableLargeParticleValue = LargeParticleValue(value: resultValue!.doubleValue, largeParticleChannel: channel as! LargeParticleChannel)
                        } else if (channel is SmallParticleChannel) {
                            honeybee.readableSmallParticleValue = SmallParticleValue(value: resultValue!.doubleValue, smallParticleChannel: channel as! SmallParticleChannel)
                        }
                        honeybee.lastTime = resultTime!.doubleValue
                    } else {
                        if maxTime <= resultTime!.doubleValue {
                            if (channel is LargeParticleChannel) {
                                honeybee.readableLargeParticleValue = LargeParticleValue(value: resultValue!.doubleValue, largeParticleChannel: channel as! LargeParticleChannel)
                            } else if (channel is SmallParticleChannel) {
                                honeybee.readableSmallParticleValue = SmallParticleValue(value: resultValue!.doubleValue, smallParticleChannel: channel as! SmallParticleChannel)
                            }
                            honeybee.lastTime = resultTime!.doubleValue
                        } else {
                            if (channel is LargeParticleChannel) {
                                honeybee.readableLargeParticleValue = nil
                            } else if (channel is SmallParticleChannel) {
                                honeybee.readableSmallParticleValue = nil
                            }
                            NSLog("found FEED VALUE out of bounds")
                            honeybee.lastTime = resultTime!.doubleValue
                        }
                    }
                    GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
                }
                
            }
        }
        
        // make & send request
        if let apiKey = feedApiKey {
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + apiKey + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
        } else {
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
        }
    }
    
    
    // ASSERT: cannot pass both authToken and feedApiKey (if so, authToken takes priority)
    func requestChannelReading(_ authToken: String?, feedApiKey: String?, feed: Pm25Feed, channel: Channel, maxTime: Double?) {
        let feedId = channel.feed!.feed_id.description
        let channelName = channel.name
        
        // handles http response
        func completionHandler(_ url: URL?, response: URLResponse?, error: Error?) -> Void {
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                var temp:NSDictionary
                
                // NOTE (from Chris)
                // "don't expect mostRecentDataSample to always exist in the response for every channel,
                // and don't expect channelBounds.maxTimeSecs to always equal mostRecentDataSample.timeSecs"
                temp = data?.value(forKey: "data") as! NSDictionary
                temp = temp.value(forKey: "channels") as! NSDictionary
                temp = temp.value(forKey: channelName) as! NSDictionary
                temp = temp.value(forKey: "mostRecentDataSample") as! NSDictionary
                
                let resultValue = temp.value(forKey: "value") as? NSNumber
                let resultTime = temp.value(forKey: "timeSecs") as? NSNumber
                if resultValue != nil && resultTime != nil {
                    if maxTime == nil {
                        if (channel is Pm25Channel) {
                            let value = Pm25_InstantCast(value: resultValue!.doubleValue, pm25Channel: channel as! Pm25Channel)
                            feed.readablePm25Value = value
                            if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                address.readablePm25Value = value
                            }
                        } else if (channel is OzoneChannel) {
                            let value = Ozone_InstantCast(value: resultValue!.doubleValue, ozoneChannel: channel as! OzoneChannel)
                            (feed as! AirQualityFeed).readableOzoneValue = value
                            if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                address.readableOzoneValue = value
                            }
                        } else if (channel is HumidityChannel) {
                            (feed as! Speck).readableHumidityValue = HumidityValue(value: resultValue!.doubleValue, humidityChannel: channel as! HumidityChannel)
                        } else if (channel is TemperatureChannel) {
                            (feed as! Speck).readableTemperatureValue = TemperatureValue(value: resultValue!.doubleValue, temperatureChannel: channel as! TemperatureChannel)
                        }
                        feed.lastTime = resultTime!.doubleValue
                    } else {
                        if maxTime <= resultTime!.doubleValue {
                            if (channel is Pm25Channel) {
                                let value = Pm25_InstantCast(value: resultValue!.doubleValue, pm25Channel: channel as! Pm25Channel)
                                feed.readablePm25Value = value
                                if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                    address.readablePm25Value = value
                                }
                            } else if (channel is OzoneChannel) {
                                let value = Ozone_InstantCast(value: resultValue!.doubleValue, ozoneChannel: channel as! OzoneChannel)
                                (feed as! AirQualityFeed).readableOzoneValue = value
                                if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                    address.readableOzoneValue = value
                                }
                            } else if (channel is HumidityChannel) {
                                (feed as! Speck).readableHumidityValue = HumidityValue(value: resultValue!.doubleValue, humidityChannel: channel as! HumidityChannel)
                            } else if (channel is TemperatureChannel) {
                                (feed as! Speck).readableTemperatureValue = TemperatureValue(value: resultValue!.doubleValue, temperatureChannel: channel as! TemperatureChannel)
                            }
                            feed.lastTime = resultTime!.doubleValue
                        } else {
                            if (channel is Pm25Channel) {
                                feed.readablePm25Value = nil
                                if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                    address.readablePm25Value = nil
                                }
                            } else if (channel is OzoneChannel) {
                                (feed as! AirQualityFeed).readableOzoneValue = nil
                                if let address = (feed as? AirQualityFeed)?.simpleAddress {
                                    address.readableOzoneValue = nil
                                }
                            } else if (channel is HumidityChannel) {
                                (feed as! Speck).readableHumidityValue = nil
                            } else if (channel is TemperatureChannel) {
                                (feed as! Speck).readableTemperatureValue = nil
                            }
                            NSLog("found FEED VALUE out of bounds")
                            feed.lastTime = resultTime!.doubleValue
                        }
                    }
                    GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
                }
                
            }
        }
        
        // make & send request
        if let token = authToken {
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendAuthorizedJsonRequest(token, urlRequest: request as URLRequest, completionHandler: completionHandler)
        } else if let apiKey = feedApiKey {
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + apiKey + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
        } else {
            let request = HttpHelper.generateRequest(Constants.Esdr.API_URL + "/api/v1/feeds/" + feedId + "/channels/" + channelName + "/most-recent", httpMethod: "GET")
            GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
        }
    }
    
    
    func requestFeeds(_ location: Location, withinSeconds: Double, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Void) ) {
        let bottomLeftPoint = Location(latitude: location.latitude - Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude - Constants.MapGeometry.BOUNDBOX_LONG)
        let topRightPoint = Location(latitude: location.latitude + Constants.MapGeometry.BOUNDBOX_LAT, longitude: location.longitude + Constants.MapGeometry.BOUNDBOX_LONG)
        
        // make & send request
        let request = HttpHelper.generateRequest(
            Constants.Esdr.API_URL +
                "/api/v1/feeds" +
                "?whereJoin=AND&whereOr=productId=11,productId=1" +
                "&whereAnd=latitude>=\(bottomLeftPoint.latitude),latitude<=\(topRightPoint.latitude),longitude>=\(bottomLeftPoint.longitude),longitude<=\(topRightPoint.longitude),maxTimeSecs>=\(withinSeconds),exposure=outdoor" +
                "&fields=id,name,exposure,isMobile,latitude,latitude,longitude,productId,channelBounds",
            httpMethod: "GET")
        GlobalHandler.sharedInstance.httpRequestHandler.sendJsonRequest(request as URLRequest, completionHandler: completionHandler)
    }
    
    
    func requestChannelReading(_ feed: Pm25Feed, channel: Channel) {
        // TODO instantcast vs nowcast
        //requestChannelReading(nil, feedApiKey: nil, feed: feed, channel: channel, maxTime: nil)
        channel.requestNowCast()
        
//        if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Pm25Feed.ReadableValueType.INSTANTCAST {
//            requestChannelReading(nil, feedApiKey: nil, feed: feed, channel: channel, maxTime: nil)
//        } else if Constants.DEFAULT_ADDRESS_READABLE_VALUE_TYPE == Feed.ReadableValueType.NOWCAST {
//            channel.requestNowCast()
//        }
    }
    
    
    func requestAuthorizedChannelReading(_ authToken: String, feed: Pm25Feed, channel: Channel) {
        let timeRange = Date().timeIntervalSince1970 - Constants.SPECKS_MAX_TIME_RANGE
        requestChannelReading(authToken, feedApiKey: nil, feed: feed, channel: channel, maxTime: timeRange)
    }
    
    
    func requestUpdate(_ readable: Readable) {
        if readable is SimpleAddress {
            let simpleAddress = readable as! SimpleAddress
            simpleAddress.requestReadablePm25Reading()
            simpleAddress.requestReadableOzoneReading()
        } else if readable is Speck {
            let speck = readable as! Speck
            speck.requestReadablePm25Reading()
            speck.requestReadableHumidityReading()
            speck.requestReadableTemperatureReading()
        } else if readable is Honeybee {
            let honeybee = readable as! Honeybee
            honeybee.requestReadableLargeParticleReading()
            honeybee.requestReadableSmallParticleReading()
        } else {
            NSLog("ERROR - Tried to requestUpdate on Readable \(readable.getName()) but class not supported")
        }
    }
    
}
