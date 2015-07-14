//
//  AddressListTableViewCell.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit

class AddressListTableViewCell: UITableViewCell {
    
    @IBOutlet var labelAddressList: UILabel!
    
    func populate(address: SimpleAddress) {
        // TODO given input, populate the cell
        labelAddressList.text = address.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
