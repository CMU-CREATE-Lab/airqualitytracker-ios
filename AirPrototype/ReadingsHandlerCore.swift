//
//  ReadingsHandlerCore.swift
//  AirPrototype
//
//  Created by mtasota on 12/22/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation

import UIKit

class ReadingsHandlerCore {
    
    var addresses = [SimpleAddress]()
    var specks = [Speck]()
    var headers = Constants.HEADER_TITLES
    var hashMap = [String: [Readable]]()
    
    
    func updateAddresses() {
        for address in addresses {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdateFeeds(address)
        }
    }
    
    
    func updateSpecks() {
        for speck in specks {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(speck)
        }
    }
    
    
    func addReading(readable: Readable) {
        let type = readable.getReadableType()
        switch type {
        case ReadableType.ADDRESS:
            addresses.append(readable as! SimpleAddress)
        case ReadableType.SPECK:
            specks.append(readable as! Speck)
        default:
            NSLog("Tried to add Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    func clearSpecks() {
        // TODO make this clear the table instead of iterating?
        for speck in self.specks {
            SpeckDbHelper.deleteSpeckFromDb(speck)
        }
        self.specks.removeAll(keepCapacity: true)
        refreshHash()
    }
    
    
    func refreshHash() {
        var tempReadables: [Readable]
        hashMap.removeAll(keepCapacity: true)
        
        // specks
        if specks.count > 0 {
            tempReadables = [Readable]()
            for speck in specks {
                tempReadables.append(speck)
            }
            hashMap[Constants.HEADER_TITLES[0]] = tempReadables
        } else {
            hashMap[Constants.HEADER_TITLES[0]] = specks
        }
        
        // cities
        tempReadables = [Readable]()
        for address in addresses {
            tempReadables.append(address)
        }
        hashMap[Constants.HEADER_TITLES[1]] = tempReadables
    }
    
    
    private func findIndexOfSpeckWithDeviceId(deviceId: Int) -> Int? {
        var i=0
        for speck in specks {
            if speck.deviceId == deviceId {
                return i
            }
            i+=1
        }
        return nil
    }
    
    
    func populateSpecks() {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let authToken = GlobalHandler.sharedInstance.settingsHandler.accessToken
            let userId = GlobalHandler.sharedInstance.settingsHandler.userId
            
            func feedsCompletionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                let httpResponse = response as! NSHTTPURLResponse
                if error != nil {
                    // ensure we don't receive an error while trying to grab feeds
                } else if httpResponse.statusCode != 200 {
                    // not sure if necessary... error usually is not nil but crashed
                    // on me one time when starting up simulator & running
                    NSLog("Got status code \(httpResponse.statusCode) != 200")
                } else {
                    let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                    var resultSpecks: Array<Speck>
                    resultSpecks = EsdrJsonParser.populateSpecksFromJson(data!)
                    for speck in resultSpecks {
                        // only add what isnt in the DB already
                        if findIndexOfSpeckWithDeviceId(speck.deviceId) == nil {
                            self.specks.append(speck)
                            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(speck)
                        }
                    }
                    if resultSpecks.count > 0 {
                        GlobalHandler.sharedInstance.esdrSpecksHandler.requestSpeckDevices(authToken!, userId: userId!, completionHandler: devicesCompletionHandler)
                    }
                }
            }
            func devicesCompletionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                let httpResponse = response as! NSHTTPURLResponse
                if error != nil {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("Failed in the devicesCompletionHandler")
                    dispatch_async(dispatch_get_main_queue()) {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else if httpResponse.statusCode != 200 {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("4Got status code \(httpResponse.statusCode) != 200")
                    dispatch_async(dispatch_get_main_queue()) {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else {
                    let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as! NSDictionary
                    if let rows = (data.valueForKey("data") as! NSDictionary).valueForKey("rows") as? Array<NSDictionary> {
                        var deviceId: Int
                        var prettyName: String
                        for row in rows {
                            deviceId = row.valueForKey("id") as! Int
                            prettyName = row.valueForKey("name") as! String
                            if let index = findIndexOfSpeckWithDeviceId(deviceId) {
                                if specks[index]._id == nil {
                                    specks[index].name = prettyName
                                }
                            }
                        }
                    }
                    // add all specks into the database which arent in there already
                    for speck in specks {
                        if speck._id == nil {
                            SpeckDbHelper.addSpeckToDb(speck)
                        }
                    }
                    refreshHash()
                }
            }
            GlobalHandler.sharedInstance.esdrSpecksHandler.requestSpeckFeeds(authToken!, userId: userId!, completionHandler: feedsCompletionHandler)
        }
        refreshHash()
    }
    
}