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
    fileprivate func getFramefromViews(_ views: [UIView?]) -> CGRect {
        var result = CGRect(x: 0, y: 0, width: 0, height: 0)
        for view in views {
            result = result.union((view?.frame)!)
        }
        return result
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func clickButtonLogin(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login"), animated: true)
    }
    
    
    @IBAction func clickButtonAboutAirQuality(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutAirQuality"), animated: true)
    }
    
    
    @IBAction func clickButtonAboutSpeck(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutSpeck"), animated: true)
    }
    
    
    @IBAction func clickButtonManageTrackers(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        parentNavigationController!.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageTrackers"), animated: true)
    }
    
    
    // MARK: UIView Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // calculates how large the popup window should be
        let frame = getFramefromViews([buttonManageTrackers, buttonLogin, buttonAboutAirQuality, buttonAboutSpeck])
        self.preferredContentSize = CGSize(width: frame.width + 20, height: frame.height)
    }
    
}
