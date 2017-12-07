//
//  SecretMenuTableCell.swift
//  AirPrototype
//
//  Created by mtasota on 11/2/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class SecretMenuTableCell: UITableViewCell {
    
    @IBOutlet var labelFeedName: UILabel!
    @IBOutlet var labelFeedDistance: UILabel!
    @IBOutlet var labelLatitude: UILabel!
    @IBOutlet var labelLongitude: UILabel!
    @IBOutlet var labelFeedValue: UILabel!
    @IBOutlet var labelFeedId: UILabel!
    
    
    func populate(_ feed: Pm25Feed, fromAddress address: SimpleAddress, tableView: UITableView) {
        labelFeedName.text = feed.getName()
        labelLatitude.text = feed.location.latitude.description
        labelLongitude.text = feed.location.longitude.description
        labelFeedValue.text = feed.getReadablePm25Value().getValue().description
        let distance = MapGeometry.getDistance(address.location, to: feed.location)
        labelFeedDistance.text = "\(Pm25AqiConverter.decimalPrecision(distance, digits: 2)) mi"
        labelFeedId.text = "id=\(feed.feed_id.description)"
    }
    
}
