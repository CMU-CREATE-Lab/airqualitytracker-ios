//
//  AqiExplanation.swift
//  AirPrototype
//
//  Created by mtasota on 3/1/16.
//  Copyright © 2016 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AqiExplanationDetailsController: UIViewController {
    
    var reading: AirNowReadable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("AqiExplanationDetailsController did load with reading=\(reading!.getName())")
    }
    
}