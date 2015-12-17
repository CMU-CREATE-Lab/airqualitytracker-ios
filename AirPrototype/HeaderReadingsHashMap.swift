//
//  HeaderReadingsHashMap.swift
//  AirPrototype
//
//  Created by mtasota on 9/2/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

class HeaderReadingsHashMap {
    
    var gpsAddress: SimpleAddress
    var addresses = [SimpleAddress]()
    var specks = [Speck]()
    var headers = Constants.HEADER_TITLES
    var hashMap = [String: [Readable]]()
    var adapterList = [String: [Readable]]()
    var adapterListTracker = [String: [Readable]]()
    
    
    init() {
        gpsAddress = SimpleAddress()
        gpsAddress.isCurrentLocation = true
        gpsAddress.name = "Loading Current Location"
        gpsAddress.location = Location(latitude: 0, longitude: 0)
        
        hashMap[headers[0]] = specks
        if SettingsHandler.sharedInstance.appUsesLocation {
            var tempAddresses = [Readable]()
            tempAddresses.append(gpsAddress)
            for address in addresses {
                tempAddresses.append(address)
            }
            hashMap[headers[1]] = tempAddresses
        } else {
            hashMap[headers[1]] = addresses
        }
        populateSpecks()
    }
    
    
    // required helpers to get the index since find() does not properly
    // match objects that should be equivalent.
    private func findIndexFromAddress(address: SimpleAddress) -> Int? {
        let max = addresses.endIndex - 1
        for i in 0...max {
            if addresses[i] === address {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from address")
        return nil
    }
    
    
    private func findIndexFromSpeck(speck: Speck) -> Int? {
        let max = specks.endIndex - 1
        for i in 0...max {
            if specks[i] === speck {
                return i
            }
        }
        NSLog("WARNING - Failed to find index from speck")
        return nil
    }
    
    
    private func reorderAddressPositions() {
        // TODO this is slow; it could be sped up if we group the jobs together (so we only have to save/synchronize once)
        var index = 1
        for address in addresses {
            address.positionId = index
            AddressDbHelper.updateAddressInDb(address)
            index += 1
        }
        SettingsHandler.sharedInstance.setAddressLastPosition(index)
    }
    
    
    private func reorderSpeckPositions() {
        // TODO this is slow; it could be sped up if we group the jobs together (so we only have to save/synchronize once)
        var index = 1
        for speck in specks {
            speck.positionId = index
            SpeckDbHelper.updateSpeckInDb(speck)
            index += 1
        }
        SettingsHandler.sharedInstance.setSpeckLastPosition(index)
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
    
    
    func populateAdapterList() {
        var items: [Readable]
        headers.removeAll(keepCapacity: true)
        
        
        adapterList.removeAll(keepCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            
            if header == Constants.HEADER_TITLES[1] && SettingsHandler.sharedInstance.appUsesLocation {
                items.insert(gpsAddress, atIndex: 0)
                adapterList[header] = items
                headers.append(header)
            } else if items.count > 0 {
                adapterList[header] = items
                headers.append(header)
            }
        }
        
        adapterListTracker.removeAll(keepCapacity: true)
        for header in Constants.HEADER_TITLES {
            items = hashMap[header]!
            if items.count > 0 {
                adapterListTracker[header] = items
            }
        }
    }
    
    
    func setGpsAddressLocation(location: Location) {
        gpsAddress.location = location
        gpsAddress.requestUpdateFeeds()
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
    
    
    func removeReading(readable: Readable) {
        let type = readable.getReadableType()
        switch type {
        case ReadableType.ADDRESS:
            if let index = findIndexFromAddress(readable as! SimpleAddress) {
                addresses.removeAtIndex(index)
            }
        case ReadableType.SPECK:
            if let speckIndex = findIndexFromSpeck(readable as! Speck) {
                specks.removeAtIndex(speckIndex)
            }
        default:
            NSLog("Tried to remove Readable of unknown Type in HeaderReadingsHashMap")
        }
        refreshHash()
    }
    
    
    // TODO add for Specks as well
    func renameReading(reading: Readable, name: String) {
        if reading.getReadableType() == ReadableType.ADDRESS {
            let address = reading as! SimpleAddress
            address.name = name
            AddressDbHelper.updateAddressInDb(address)
        } else if reading.getReadableType() == ReadableType.SPECK {
            let speck = reading as! Speck
            speck.name = name
            SpeckDbHelper.updateSpeckInDb(speck)
        }
    }
    
    
    func reorderReading(reading: Readable, destination: Readable) {
        if reading.getReadableType() == destination.getReadableType() {
            if reading.getReadableType() == ReadableType.ADDRESS {
                let from = findIndexFromAddress(reading as! SimpleAddress)
                let to = findIndexFromAddress(destination as! SimpleAddress)
                addresses.removeAtIndex(from!)
                addresses.insert(reading as! SimpleAddress, atIndex: to!)
            } else if reading.getReadableType() == ReadableType.SPECK {
                let from = findIndexFromSpeck(reading as! Speck)
                let to = findIndexFromSpeck(destination as! Speck)
                specks.removeAtIndex(from!)
                specks.insert(reading as! Speck, atIndex: to!)
            }
            reorderAddressPositions()
            reorderSpeckPositions()
            refreshHash()
        }
    }
    
    
    func updateAddresses() {
        for address in addresses {
            address.requestUpdateFeeds()
        }
    }
    
    
    func updateSpecks() {
        for speck in specks {
            speck.requestUpdate()
        }
    }
    
    
    func clearSpecks() {
        // TODO make this clear the table instead of iterating?
        for speck in self.specks {
            SpeckDbHelper.deleteSpeckFromDb(speck)
        }
        self.specks.removeAll(keepCapacity: true)
        refreshHash()
    }
    
    
    func populateSpecks() {
        if SettingsHandler.sharedInstance.userLoggedIn {
            let authToken = SettingsHandler.sharedInstance.accessToken
            let userId = SettingsHandler.sharedInstance.userId
            
            func feedsCompletionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                var resultSpecks: Array<Speck>
                resultSpecks = JsonParser.populateSpecksFromJson(data!)
                for speck in resultSpecks {
                    // only add what isnt in the DB already
                    if findIndexOfSpeckWithDeviceId(speck.deviceId) == nil {
                        self.specks.append(speck)
                        speck.requestUpdate()
                    }
                }
                if resultSpecks.count > 0 {
                    EsdrSpecksHandler.sharedInstance.requestSpeckDevices(authToken!, userId: userId!, completionHandler: devicesCompletionHandler)
                }
            }
            func devicesCompletionHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
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
            EsdrSpecksHandler.sharedInstance.requestSpeckFeeds(authToken!, userId: userId!, completionHandler: feedsCompletionHandler)
        }
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
        
        populateAdapterList()
        
        if GlobalHandler.singletonInstantiated {
            GlobalHandler.sharedInstance.notifyGlobalDataSetChanged()
        }
    }
    
}