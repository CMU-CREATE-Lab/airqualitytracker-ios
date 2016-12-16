//
//  ManageTrackersTableViewCell.swift
//  AirPrototype
//
//  Created by mtasota on 10/19/15.
//  Copyright © 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

class ManageTrackersTableViewCell: UITableViewCell, UIAlertViewDelegate {
    
    @IBOutlet var editName: UIButton!
    @IBOutlet var labelReadingName: UILabel!
    var reading: Readable?
    var tableView: UITableView?
    
    
    func populate(reading: Readable, tableView: UITableView) {
        self.reading = reading
        self.tableView = tableView
        labelReadingName.text = reading.getName()
    }
    
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1{
            let name = alertView.textFieldAtIndex(0)!.text!
            GlobalHandler.sharedInstance.readingsHandler.renameReading(self.reading!, name: name)
            self.tableView!.reloadData()
        }
    }
    
    
    // MARK: Storyboard Events
    
    
    @IBAction func onClickEditName(sender: AnyObject) {
        let reading = self.reading!
        if (reading is SimpleAddress) {
            let dialog = UIAlertView.init(title: "Change Address Name", message: reading.getName(), delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Save")
            dialog.alertViewStyle = UIAlertViewStyle.PlainTextInput
            dialog.show()
        } else if (reading is Speck) {
            let dialog = UIAlertView.init(title: "Change Address Name", message: reading.getName(), delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Save")
            dialog.alertViewStyle = UIAlertViewStyle.PlainTextInput
            dialog.show()
        } else {
            NSLog("Error - could not find readable type")
        }
    }
    
}
