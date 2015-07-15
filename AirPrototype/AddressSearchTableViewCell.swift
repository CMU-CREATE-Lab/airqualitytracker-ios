//
//  AddressSearchTableViewCell.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit

class AddressSearchTableViewCell: UITableViewCell {
    
    @IBOutlet var labelAddressSearch: UILabel!
    
    
    func populate(address: SimpleAddress) {
        // TODO given input, populate the cell
        labelAddressSearch.text = address.name
        self.viewForBaselineLayout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
