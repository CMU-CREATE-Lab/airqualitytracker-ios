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
    var feed: Pm25Feed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("AqiExplanationDetailsController did load with reading=\(reading!.getName())")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAirNowSegue" {
            let controller = segue.destinationViewController as! AirNowDetailsController
            controller.reading = self.reading
        } else {
            NSLog("ERROR - bad segue name")
        }
    }
    
}
