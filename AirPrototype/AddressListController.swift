//
//  AddressListController.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit

class AddressListController: UITableViewController {
    
    @IBOutlet var tableViewAddressList: UITableView!
    @IBOutlet var addBarButtonAddressList: UIBarButtonItem!
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "reuseAddressList"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddressListTableViewCell
        
        cell.populate(addressList[indexPath.row])
        return cell
    }
    
    
    @IBAction func addBarButtonOnTouch(sender: UIBarButtonItem) {
        NSLog("LOGGING STARTS HERE");
        var addedAddress = SimpleAddress()
        addedAddress.name = "Address #" + String(addressList.count+1)
        addressList.append(addedAddress)
        NSLog("Added address " + addedAddress.name);
        tableViewAddressList.reloadData()
    }
    
    
    
}

