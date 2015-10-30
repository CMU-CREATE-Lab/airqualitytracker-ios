//
//  AboutSpeckController.swift
//  AirPrototype
//
//  Created by mtasota on 10/6/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AboutSpeckController:UIViewController {
    
    @IBOutlet var labelTitleAppVersion: UILabel!
    @IBOutlet var labelVersion: UILabel!
    
    
    override func viewDidLoad() {
        labelVersion.text = Constants.APP_VERSION_NUMBER
    }
    
}