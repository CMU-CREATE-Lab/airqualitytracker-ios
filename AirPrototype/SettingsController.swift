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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("SettingsController did load!")
        currentLocationSwitch.on = SettingsHandler.sharedInstance.appUsesLocation
    }
    
    
    @IBAction func onSwitchUserCurrentLocation(sender: AnyObject) {
        SettingsHandler.sharedInstance.setAppUsesCurrentLocation(currentLocationSwitch.on)
    }
    
}