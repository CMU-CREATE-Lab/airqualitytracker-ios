//
//  CLLocationService.swift
//  AirPrototype
//
//  Created by mtasota on 9/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class CLLocationSService: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    // This is set to false if location services are not enabled on the device or if this app is denied service
    var serviceEnabled: Bool = false
    
    
    fileprivate func updateCurrentLocation(_ location: Location, name: String) {
        GlobalHandler.sharedInstance.readingsHandler.gpsReadingHandler.gpsAddress.name = name
        GlobalHandler.sharedInstance.readingsHandler.refreshHash()
    }
    
    
    func startLocationService() {
        if (serviceEnabled) {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 1000
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func stopLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
    
    // MARK: Location Manager
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus != .denied && authStatus != .restricted && authStatus != .notDetermined {
                serviceEnabled = true
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = manager.location
        GlobalHandler.sharedInstance.readingsHandler.gpsReadingHandler.setGpsAddressLocation(Location(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude))
        
        geocoder.reverseGeocodeLocation(location!, completionHandler: { (results: [CLPlacemark]?, error: NSError?) -> Void in
            if error == nil && results!.count > 0 {
                let placemark = results![results!.endIndex-1]
                self.updateCurrentLocation(Location(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude), name: placemark.locality!)
            }
        } as! CLGeocodeCompletionHandler)
        // TODO should we stop updating location once we find one?
//        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("FAIL at CLLocationSService")
        updateCurrentLocation(Location(latitude:0,longitude:0), name: "Unknown Location")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus != .denied && authStatus != .restricted && authStatus != .notDetermined {
            serviceEnabled = true
            startLocationService()
        } else {
            serviceEnabled = false
        }
        if authStatus == .denied || authStatus == .restricted {
            GlobalHandler.sharedInstance.settingsHandler.setAppUsesCurrentLocation(false)
        }
    }
    
}
