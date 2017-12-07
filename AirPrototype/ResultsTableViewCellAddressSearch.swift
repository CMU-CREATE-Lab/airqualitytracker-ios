//
//  ResultsTableViewCellAddressSearch.swift
//  AirPrototype
//
//  Created by mtasota on 7/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ResultsTableViewCellAddressSearch: UITableViewCell {
    
    @IBOutlet var labelResultsTableViewCellAddressSearch: UILabel!
    
    
    func populate(_ address: SimpleAddress) {
        labelResultsTableViewCellAddressSearch.text = address.name
        self.forBaselineLayout()
    }
    
    
    // MARK: Table View Cell
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
