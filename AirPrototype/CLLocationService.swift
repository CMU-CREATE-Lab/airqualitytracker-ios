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
    override init() {
        super.init()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus != .Denied && authStatus != .Restricted && authStatus != .NotDetermined {
                serviceEnabled = true
            }
        }
    }
    
    
    private func updateCurrentLocation(location: Location, name: String) {
        GlobalHandler.sharedInstance.headerReadingsHashMap.gpsAddress.name = name
        GlobalHandler.sharedInstance.headerReadingsHashMap.refreshHash()
    }
    
    
    func startLocationService() {
        if (serviceEnabled) {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 1000
            locationManager.startUpdatingLocation()
            if locationManager.location != nil {
                let latitude = locationManager.location.coordinate.latitude
                let longitude = locationManager.location.coordinate.longitude
            }
        }
    }
    
    
    func stopLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = manager.location
        GlobalHandler.sharedInstance.headerReadingsHashMap.setGpsAddressLocation(Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        NSLog("CLLocationSService -- Received new locations: Coordinates are lat=\(location.coordinate.latitude),long=\(location.coordinate.longitude)")
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (results: [AnyObject]!, error: NSError!) -> Void in
            if error == nil && results.count > 0 {
                let placemark = results[results.endIndex-1] as! CLPlacemark
                NSLog("Reverse Geocode discovered locality=\(placemark.locality), zip=\(placemark.postalCode), country=\(placemark.country)")
                self.updateCurrentLocation(Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), name: placemark.locality)
            }
        })
        // TODO should we stop updating location once we find one?
//        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("FAIL at CLLocationSService")
        updateCurrentLocation(Location(latitude:0,longitude:0), name: "Unknown Location")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        NSLog("didChangeAuthorizationStatus")
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus != .Denied && authStatus != .Restricted && authStatus != .NotDetermined {
            serviceEnabled = true
            startLocationService()
        } else {
            serviceEnabled = false
        }
        NSLog("Location Authorization Status changed to \(authStatus.rawValue); setting serviceEnabled=\(serviceEnabled)")
        if authStatus == .Denied || authStatus == .Restricted {
            SettingsHandler.sharedInstance.setAppUsesCurrentLocation(false)
        }
    }
    
}