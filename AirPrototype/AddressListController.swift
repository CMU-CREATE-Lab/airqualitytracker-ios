//
//  AddressListController.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit

class AddressListController: UITableViewController {
    
    // interface
    @IBOutlet var tableViewAddressList: UITableView!
    // keeps track of list of addresses
    var addressList = Array<SimpleAddress>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addressList = GlobalHandler.sharedInstance.requestAddressesForDisplay()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableView delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellReuseIdentifiers.ADDRESS_LIST, forIndexPath: indexPath) as! AddressListTableViewCell
        
        cell.populate(addressList[indexPath.row])
        return cell
    }
    
}

