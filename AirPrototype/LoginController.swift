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
    
    override func viewWillAppear(_ animated: Bool) {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            if GlobalHandler.sharedInstance.esdrAuthHandler.alertLogout() {
                UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
                loggedIn = false
                self.display()
            } else {
                let timestamp = Int(Date().timeIntervalSince1970)
                let refreshToken = GlobalHandler.sharedInstance.esdrAccount.refreshToken!
                
                // response handler
                func responseHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                    if error != nil {
                        NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                        GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens("", refreshToken: "", expiresAt: 0)
                    } else {
                        let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary
                        let access_token = data!.value(forKey: "access_token") as? String
                        let refresh_token = data!.value(forKey: "refresh_token") as? String
                        let expires_in = data!.value(forKey: "expires_in") as? Int
                        if access_token != nil && refresh_token != nil && expires_in != nil {
                            NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                            GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                            NSLog("Updated ESDR Tokens!")
                        } else {
                            GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                            NSLog("Failed to grab access/refresh token(s)")
                            UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
                            loggedIn = false
                            self.display()
                        }
                    }
                }
                
                GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
            }
        }
    }
    
    
    func display() {
        if loggedIn {
            logoutView = Bundle.main.loadNibNamed("LogoutView", owner: contentView, options: nil)!.last as? LogoutView
            logoutView!.frame = contentView.frame
            logoutView!.frame.origin = CGPoint(x: 0,y: 0)
            contentView.addSubview(logoutView!)
            
            if loginView != nil {
                loginView!.removeFromSuperview()
                loginView = nil
            }
            logoutView!.labelUsername.text = username
            logoutView!.logoutButton.addTarget(self, action: #selector(LoginController.onClickLogout), for: UIControlEvents.touchDown)
        } else {
            loginView = Bundle.main.loadNibNamed("LoginView", owner: contentView, options: nil)!.last as? LoginView
            loginView!.frame = contentView.frame
            loginView!.frame.origin = CGPoint(x: 0,y: 0)
            contentView.addSubview(loginView!)
            
            if logoutView != nil {
                logoutView!.removeFromSuperview()
                logoutView = nil
            }
            loginView!.loginButton.addTarget(self, action: #selector(LoginController.onClickLogin), for: UIControlEvents.touchDown)
        }
    }
    
    
    func onClickLogin() {
        let timestamp = Int(Date().timeIntervalSince1970)
        username = loginView!.textFieldUsername.text
        let password = loginView!.textFieldPassword.text
        
        GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrToken(username!, password: password!, completionHandler: { (url: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if HttpHelper.successfulResponse(response, error: error) {
                let data = (try! JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as! NSDictionary
                let accessToken = data.value(forKey: "access_token") as! String
                let refreshToken = data.value(forKey: "refresh_token") as! String
                let expires_in = data.value(forKey: "expires_in") as! Int
                let userId = data.value(forKey: "userId") as! Int
                
                let esdrLoginHandler = GlobalHandler.sharedInstance.esdrLoginHandler
                esdrLoginHandler.updateEsdrAccount(self.username!, userId: userId, accessToken: accessToken, refreshToken: refreshToken, expiresAt: timestamp+expires_in)
                esdrLoginHandler.setUserLoggedIn(true)
            }
            if self.loggedIn == false {
                DispatchQueue.main.async {
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
        GlobalHandler.sharedInstance.readingsHandler.clearHoneybees()
        display()
    }
    
}
