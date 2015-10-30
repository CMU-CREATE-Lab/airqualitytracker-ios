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
    
    // ASSERT: assumes we want the top-left corner included
    private func getFramefromViews(views: [UIView!]) -> CGRect {
        var result = CGRectMake(0, 0, 0, 0)
        for view in views {
            result = CGRectUnion(result, view.frame)
        }
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // calculates how large the popup window should be
        let frame = getFramefromViews([buttonManageTrackers, buttonLogin, buttonAboutAirQuality, buttonAboutSpeck])
        self.preferredContentSize = CGSizeMake(frame.width + 20, frame.height)
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