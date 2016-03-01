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
    var feed: Feed?
    
    @IBOutlet var labelFeedName: UILabel!
    @IBOutlet var labelLatitude: UILabel!
    @IBOutlet var labelLongitude: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("AqiExplanationDetailsController did load with reading=\(reading!.getName())")
        
        labelFeedName.text = "Feed name: \(feed!.getName())"
        labelLatitude.text = "Latitude: \(feed!.location.latitude)"
        labelLongitude.text = "Longitude: \(feed!.location.longitude)"
    }
    
}