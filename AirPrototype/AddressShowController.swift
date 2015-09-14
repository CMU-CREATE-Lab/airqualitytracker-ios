//
//  AddressShowController.swift
//  AirPrototype
//
//  Created by mtasota on 7/20/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class AddressShowController: UIViewController {
    
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelLatitude: UILabel!
    @IBOutlet var labelLongitude: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var mainView: UIView!
    var address: SimpleAddress?
    
    func populateView() {
        labelName.text = address!.name
        labelLatitude.text = address!.location.latitude.description
        labelLongitude.text = address!.location.longitude.description
        
        var gradient = CAGradientLayer()
        gradient.frame = mainView.bounds
        
        let start = Constants.AqiReading.aqiGradientColorStart[0]
        let end = Constants.AqiReading.aqiGradientColorEnd[0]
        gradient.colors = [
            start,
            end
        ] as [AnyObject]
        mainView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Loaded AddressShow with address " + address!.name)
        populateView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}