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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            loggedIn = true
            username = GlobalHandler.sharedInstance.esdrAccount.username
        }
        display()
    }
    
    override func viewWillAppear(animated: Bool) {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let refreshToken = GlobalHandler.sharedInstance.esdrAccount.accessToken!
            let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            
            // response handler
            func responseHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                if error != nil {
                    NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                } else {
                    let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                    let access_token = data!.valueForKey("access_token") as? String
                    let refresh_token = data!.valueForKey("refresh_token") as? String
                    let expires_in = data!.valueForKey("expires_in") as? Int
                    if access_token != nil && refresh_token != nil && expires_in != nil {
                        NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                        GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                        NSLog("Updated ESDR Tokens!")
                    } else {
                        GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                        NSLog("Failed to grab access/refresh token(s)")
                    }
                }
            }
            
            let updatingTokens = GlobalHandler.sharedInstance.esdrAuthHandler.checkAndRefreshEsdrTokens(expiresAt, currentTime: timestamp, refreshToken: refreshToken, responseHandler: responseHandler)
            if !updatingTokens {
                UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
                loggedIn = false
                self.display()
            }
        }
    }
    
    
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
    
    
    func onClickLogin() {
        let timestamp = Int(NSDate().timeIntervalSince1970)
        username = loginView!.textFieldUsername.text
        let password = loginView!.textFieldPassword.text
        
        GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrToken(username!, password: password!, completionHandler: { (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            if error != nil {
                NSLog("error is not nil")
                self.loggedIn = false
            } else if httpResponse.statusCode != 200 {
                // not sure if necessary... error usually is not nil but crashed
                // on me one time when starting up simulator & running
                NSLog("Got status code \(httpResponse.statusCode) != 200")
                self.loggedIn = false
            } else {
                let data = (try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as! NSDictionary
                let accessToken = data.valueForKey("access_token") as! String
                let refreshToken = data.valueForKey("refresh_token") as! String
                let expires_in = data.valueForKey("expires_in") as! Int
                let userId = data.valueForKey("userId") as! Int
                
                let esdrLoginHandler = GlobalHandler.sharedInstance.esdrLoginHandler
                esdrLoginHandler.updateEsdrAccount(self.username!, userId: userId, accessToken: accessToken, refreshToken: refreshToken, expiresAt: timestamp+expires_in)
                esdrLoginHandler.setUserLoggedIn(true)
            }
            if self.loggedIn == false {
                dispatch_async(dispatch_get_main_queue()) {
                    self.display()
                    let dialog = UIAlertView.init(title: "www.specksensor.com", message: "Failed to log in", delegate: nil, cancelButtonTitle: "OK")
                    dialog.show()
                }
            }
        })
        
        loggedIn = true
        display()
    }
    
    
    func onClickLogout() {
        GlobalHandler.sharedInstance.esdrLoginHandler.setUserLoggedIn(false)
        loggedIn = false
        GlobalHandler.sharedInstance.esdrLoginHandler.setUserLoggedIn(false)
        GlobalHandler.sharedInstance.readingsHandler.clearSpecks()
        display()
    }
    
}