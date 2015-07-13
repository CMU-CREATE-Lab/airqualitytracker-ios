//
//  AddressListController.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit

class AddressListController: UITableViewController {
    
    @IBOutlet var addBarButtonAddressList: UIBarButtonItem!
    var list = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        list.append("Hello")
        list.append("There")
        list.append("Listed")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "reuseAddressList"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddressListTableViewCell
        
        cell.populate(list[indexPath.row])
        return cell
    }
    
    
    @IBAction func addBarButtonOnTouch(sender: UIBarButtonItem) {
        NSLog("LOGGING STARTS HERE");
    }
    
    
    
}

