//
//  AirNowDetailsController.swift
//  AirPrototype
//
//  Created by mtasota on 3/1/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AirNowDetailsController: UIViewController {
    
    var reading: AirNowReadable?
    var feed: Feed?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("AirNowDetailsController did load with reading=\(reading!.getName())")
    }
    
}