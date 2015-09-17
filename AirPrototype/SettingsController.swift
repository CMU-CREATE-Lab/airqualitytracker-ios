//
//  SettingsController.swift
//  AirPrototype
//
//  Created by mtasota on 9/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet var currentLocationSwitch: UISwitch!
    @IBOutlet var useLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("SettingsController did load!")
        currentLocationSwitch.on = SettingsHandler.sharedInstance.appUsesLocation
        if ServicesHandler.sharedInstance.locationService.serviceEnabled == false {
            currentLocationSwitch.enabled = false
            useLocationLabel.text = "We detect that location services is restricted on your device. To enable this feature, you must turn on location services in device Settings."
        }
    }
    
    
    @IBAction func onSwitchUserCurrentLocation(sender: AnyObject) {
        SettingsHandler.sharedInstance.setAppUsesCurrentLocation(currentLocationSwitch.on)
    }
    
}