//
//  ManualOverrides.swift
//  AirPrototype
//
//  Created by Mike Tasota on 4/6/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation

class ManualOverrides {
    
    static func loginEsdr() {
        let time = Int(Date().timeIntervalSince1970) + 1209600; // 2 weeks
        let userId = Constants.ManualOverrides.userId;
        let username = Constants.ManualOverrides.username;
        let accessToken = Constants.ManualOverrides.accessToken;
        let refreshToken = Constants.ManualOverrides.refreshToken;
        
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.esdrLoginHandler.updateEsdrAccount(username,userId: userId,accessToken: accessToken,refreshToken: refreshToken,expiresAt: time);
        globalHandler.esdrLoginHandler.setUserLoggedIn(true);
    }
}
