//
//  ReadableIndexHeader.swift
//  AirPrototype
//
//  Created by mtasota on 9/9/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ReadableIndexHeader: UICollectionReusableView {
    
    @IBOutlet var textHeaderTitle: UILabel!
    
    
    func populate(_ sectionTitle: String) {
        textHeaderTitle.text = sectionTitle
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
