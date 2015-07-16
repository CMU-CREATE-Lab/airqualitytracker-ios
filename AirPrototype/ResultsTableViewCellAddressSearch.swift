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
    
    
    func populate(address: SimpleAddress) {
        // TODO given input, populate the cell
        labelResultsTableViewCellAddressSearch.text = address.name
        self.viewForBaselineLayout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
