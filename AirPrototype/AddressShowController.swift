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
    var address: SimpleAddress?
    
    func populateView() {
//        address!.latitude = 1.0
//        address!.longitude = 2.555
        labelName.text = address!.name
        labelLatitude.text = address!.latitude.description
        labelLongitude.text = address!.longitude.description
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