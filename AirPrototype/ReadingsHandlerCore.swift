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
    var honeybees = [Honeybee]()
    var specks = [Speck]()
    var headers = Constants.HEADER_TITLES
    var hashMap = [String: [Readable]]()
    
    
    func updateAddresses() {
        for address in addresses {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(address)
        }
    }
    
    
    func updateSpecks() {
        for speck in specks {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(speck)
        }
    }
    
    
    func updateHoneybees() {
        for honeybee in honeybees {
            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(honeybee)
        }
    }
    
    
    func addReading(_ readable: Readable) {
        if (readable is SimpleAddress) {
            addresses.append(readable as! SimpleAddress)
        } else if (readable is Speck) {
            specks.append(readable as! Speck)
        } else if (readable is Honeybee) {
            honeybees.append(readable as! Honeybee)
        } else {
            NSLog("Tried to add Readable of unknown Type in HeaderReadingsHashMap")
        }
//        let type = readable.getReadableType()
//        switch type {
//        case ReadableType.ADDRESS:
//            addresses.append(readable as! SimpleAddress)
//        case ReadableType.SPECK:
//            specks.append(readable as! Speck)
//        default:
//            NSLog("Tried to add Readable of unknown Type in HeaderReadingsHashMap")
//        }
        refreshHash()
    }
    
    
    func clearSpecks() {
        SpeckDbHelper.clearSpecksFromDb(self.specks)
        self.specks.removeAll(keepingCapacity: true)
        refreshHash()
    }
    
    
    func clearHoneybees() {
        HoneybeeDbHelper.clearHoneybeesFromDb(self.honeybees)
        self.honeybees.removeAll(keepingCapacity: true)
        refreshHash()
    }
    
    
    func refreshHash() {
        var tempReadables: [Readable]
        hashMap.removeAll(keepingCapacity: true)
        
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
        
        // honeybees
        if honeybees.count > 0 {
            tempReadables = [Readable]()
            for honeybee in honeybees {
                tempReadables.append(honeybee)
            }
            hashMap[Constants.HEADER_TITLES[1]] = tempReadables
        } else {
            hashMap[Constants.HEADER_TITLES[1]] = honeybees
        }

        // cities
        tempReadables = [Readable]()
        for address in addresses {
            tempReadables.append(address)
        }
        hashMap[Constants.HEADER_TITLES[2]] = tempReadables
    }
    
    
    fileprivate func findIndexOfSpeckWithDeviceId(_ deviceId: Int) -> Int? {
        var i=0
        for speck in specks {
            if speck.deviceId == deviceId {
                return i
            }
            i+=1
        }
        return nil
    }
    
    
    fileprivate func findIndexOfHoneybeeWithDeviceId(_ deviceId: Int) -> Int? {
        var i=0
        for honeybee in honeybees {
            if honeybee.deviceId == deviceId {
                return i
            }
            i+=1
        }
        return nil
    }
    
    
    func populateHoneybees() {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let authToken = GlobalHandler.sharedInstance.esdrAccount.accessToken
            let userId = GlobalHandler.sharedInstance.esdrAccount.userId
            
            func feedsCompletionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                let httpResponse = response as! HTTPURLResponse
                if error != nil {
                    // ensure we don't receive an error while trying to grab feeds
                } else if httpResponse.statusCode != 200 {
                    // not sure if necessary... error usually is not nil but crashed
                    // on me one time when starting up simulator & running
                    NSLog("Got status code \(httpResponse.statusCode) != 200")
                } else {
                    let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                    var resultHoneybees: Array<Honeybee>
                    resultHoneybees = EsdrJsonParser.populateHoneybeesFromJson(data!)
                    for honeybee in resultHoneybees {
                        // only add what isnt in the DB already
                        if findIndexOfHoneybeeWithDeviceId(honeybee.deviceId) == nil {
                            self.honeybees.append(honeybee)
                            GlobalHandler.sharedInstance.esdrFeedsHandler.requestUpdate(honeybee)
                        }
                    }
                    if resultHoneybees.count > 0 {
                        GlobalHandler.sharedInstance.esdrHoneybeesHandler.requestHoneybeeDevices(authToken!, userId: userId!, completionHandler: devicesCompletionHandler)
                    }
                }
            }
            func devicesCompletionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                let httpResponse = response as! HTTPURLResponse
                if error != nil {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("Failed in the devicesCompletionHandler")
                    DispatchQueue.main.async {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else if httpResponse.statusCode != 200 {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("4Got status code \(httpResponse.statusCode) != 200")
                    DispatchQueue.main.async {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else {
                    let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as! NSDictionary
                    if let rows = (data.value(forKey: "data") as! NSDictionary).value(forKey: "rows") as? Array<NSDictionary> {
                        var deviceId: Int
                        var prettyName: String
                        for row in rows {
                            deviceId = row.value(forKey: "id") as! Int
                            prettyName = row.value(forKey: "name") as! String
                            if let index = findIndexOfSpeckWithDeviceId(deviceId) {
                                if honeybees[index]._id == nil {
                                    honeybees[index].name = prettyName
                                }
                            }
                        }
                    }
                    // add all honeybees into the database which arent in there already
                    for honeybee in honeybees {
                        if honeybee._id == nil {
                            HoneybeeDbHelper.addHoneybeeToDb(honeybee)
                        }
                    }
                    refreshHash()
                }
            }
            GlobalHandler.sharedInstance.esdrHoneybeesHandler.requestHoneybeeFeeds(authToken!, userId: userId!, completionHandler: feedsCompletionHandler)
        }
        refreshHash()
    }
    
    
    func populateSpecks() {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let authToken = GlobalHandler.sharedInstance.esdrAccount.accessToken
            let userId = GlobalHandler.sharedInstance.esdrAccount.userId
            
            func feedsCompletionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                let httpResponse = response as! HTTPURLResponse
                if error != nil {
                    // ensure we don't receive an error while trying to grab feeds
                } else if httpResponse.statusCode != 200 {
                    // not sure if necessary... error usually is not nil but crashed
                    // on me one time when starting up simulator & running
                    NSLog("Got status code \(httpResponse.statusCode) != 200")
                } else {
                    let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
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
            func devicesCompletionHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                let httpResponse = response as! HTTPURLResponse
                if error != nil {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("Failed in the devicesCompletionHandler")
                    DispatchQueue.main.async {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else if httpResponse.statusCode != 200 {
                    // If this runs, it is likely that we are "Unauthorized"
                    // So, our token expired and we should clear everything
                    NSLog("4Got status code \(httpResponse.statusCode) != 200")
                    DispatchQueue.main.async {
                        GlobalHandler.sharedInstance.loginController?.onClickLogout()
                        UIAlertView.init(title: "www.specksensor.com", message: "Unauthorized Token", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                } else {
                    let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as! NSDictionary
                    if let rows = (data.value(forKey: "data") as! NSDictionary).value(forKey: "rows") as? Array<NSDictionary> {
                        var deviceId: Int
                        var prettyName: String
                        for row in rows {
                            deviceId = row.value(forKey: "id") as! Int
                            prettyName = row.value(forKey: "name") as! String
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
