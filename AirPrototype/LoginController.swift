//
//  LoginController.swift
//  AirPrototype
//
//  Created by mtasota on 9/17/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class LoginController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    var loginView: LoginView?
    var logoutView: LogoutView?
    var username: String?
    var loggedIn: Bool = false
    
    func display() {
        if loggedIn {
            logoutView = NSBundle.mainBundle().loadNibNamed("LogoutView", owner: contentView, options: nil).last as? LogoutView
            logoutView!.frame = contentView.frame
            logoutView!.frame.origin = CGPoint(x: 0,y: 0)
            contentView.addSubview(logoutView!)
            
            if loginView != nil {
                loginView!.removeFromSuperview()
                loginView = nil
            }
            logoutView!.labelUsername.text = username
            logoutView!.logoutButton.addTarget(self, action: "onClickLogout", forControlEvents: UIControlEvents.TouchDown)
        } else {
            loginView = NSBundle.mainBundle().loadNibNamed("LoginView", owner: contentView, options: nil).last as? LoginView
            loginView!.frame = contentView.frame
            loginView!.frame.origin = CGPoint(x: 0,y: 0)
            contentView.addSubview(loginView!)
            
            if logoutView != nil {
                logoutView!.removeFromSuperview()
                logoutView = nil
            }
            loginView!.loginButton.addTarget(self, action: "onClickLogin", forControlEvents: UIControlEvents.TouchDown)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("LoginController did load!")
        if SettingsHandler.sharedInstance.userLoggedIn {
            loggedIn = true
            username = SettingsHandler.sharedInstance.username
        }
        display()
    }
    
    func onClickLogin() {
        username = loginView!.textFieldUsername.text
        let password = loginView!.textFieldPassword.text
        HttpRequestHandler.sharedInstance.requestEsdrToken(username!, password: password, completionHandler: { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
            } else {
                let data = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url)!, options: nil, error: nil) as! NSDictionary
                let accessToken = data.valueForKey("access_token") as! String
                let refreshToken = data.valueForKey("refresh_token") as! String
                let userId = data.valueForKey("userId") as! Int
                
                let settingsHandler = SettingsHandler.sharedInstance
                settingsHandler.updateEsdrAccount(self.username!, userId: userId, accessToken: accessToken, refreshToken: refreshToken)
                settingsHandler.setUserLoggedIn(true)
                // TODO esdr refresh service?
            }
        })
        loggedIn = true
        display()
    }
    
    func onClickLogout() {
        // TODO stop esdr refresh service
        SettingsHandler.sharedInstance.setUserLoggedIn(false)
        loggedIn = false
        SettingsHandler.sharedInstance.setUserLoggedIn(false)
        GlobalHandler.sharedInstance.headerReadingsHashMap.populateSpecks()
        display()
    }
    
}