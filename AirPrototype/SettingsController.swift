//
//  SettingsController.swift
//  AirPrototype
//
//  Created by mtasota on 10/28/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet var buttonManageTrackers: UIButton!
    @IBOutlet var buttonLogin: UIButton!
    @IBOutlet var buttonAboutAirQuality: UIButton!
    @IBOutlet var buttonAboutSpeck: UIButton!
    var parentNavigationController: UINavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // calculates how large the popup window should be
        let width = self.buttonAboutAirQuality.bounds.width + 40
        let height = self.buttonAboutSpeck.frame.origin.y + self.buttonAboutSpeck.bounds.size.height
        self.preferredContentSize = CGSizeMake(width, height)
    }
    
    @IBAction func clickButtonLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login"), animated: true)
    }
    
    @IBAction func clickButtonAboutAirQuality(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AboutAirQuality"), animated: true)
    }
    
    @IBAction func clickButtonAboutSpeck(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AboutSpeck"), animated: true)
    }
    
    @IBAction func clickButtonManageTrackers(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ManageTrackers"), animated: true)
    }
    
}