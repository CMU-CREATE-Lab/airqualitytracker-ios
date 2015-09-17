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
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus != .Denied && authStatus != .Restricted && authStatus != .NotDetermined {
                serviceEnabled = true
            }
        }
        super.init()
    }
    
    
    func startLocationService() {
        if (serviceEnabled) {
            locationManager.delegate = self
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
                GlobalHandler.sharedInstance.headerReadingsHashMap.gpsAddress.name = placemark.locality
                GlobalHandler.sharedInstance.headerReadingsHashMap.refreshHash()
            }
        })
        // TODO should we stop updating location once we find one?
//        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("FAIL at CLLocationSService")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus != .Denied && authStatus != .Restricted && authStatus != .NotDetermined {
            serviceEnabled = true
        } else {
            serviceEnabled = false
        }
        NSLog("Location Authorization Status changed to \(authStatus.rawValue); setting serviceEnabled=\(serviceEnabled)")
    }
    
}