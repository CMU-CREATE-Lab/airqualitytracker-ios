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
        display()
    }
    
    func onClickLogin() {
        username = loginView!.textFieldUsername.text
        let password = loginView!.textFieldPassword.text
        // TODO request esdr token username, password, completionHandler
        loggedIn = true
        display()
    }
    
    func onClickLogout() {
        // TODO stop esdr refresh service
        SettingsHandler.sharedInstance.setUserLoggedIn(false)
        loggedIn = false
        GlobalHandler.sharedInstance.headerReadingsHashMap.populateSpecks()
        display()
    }
    
}