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
    
    
    func populate(sectionNumber: Int) {
        switch sectionNumber {
        case 0:
            textHeaderTitle.text = Constants.HEADER_TITLES[0]
        case 1:
            textHeaderTitle.text = Constants.HEADER_TITLES[1]
        default:
            NSLog("WARNING - missing section number")
            textHeaderTitle.text = ""
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}