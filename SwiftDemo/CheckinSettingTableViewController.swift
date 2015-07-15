//
//  CheckinSettingTableViewController.swift
//  Fate
//
//  Created by macos on 12/8/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit

let cellIds = ["CheckInDaysCell", "CheckInAgeRangeCell"]
class CheckinSettingTableViewController: UITableViewController, UITextFieldDelegate {
    let currentUser = PFUser.currentUser()
    var numDays : NSNumber!
    var numMiles : NSNumber!
    var numRange1 : NSNumber!
    var numRange2 : NSNumber!
    
    var tV1 : UITextField!
    var tV2 : UITextField!
    var tV3 : UITextField!
    var tV4 : UITextField!
    var titleImageView = UIImageView(image: UIImage(named: "30.png"))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        self.view.addGestureRecognizer( self.revealViewController().panGestureRecognizer())
        
        let menuImageView = UIImageView(image: UIImage(named: "Menu30.png"))
        let leftBarButton = UIBarButtonItem(image: menuImageView.image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("menuClicked"))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.navigationItem.titleView = titleImageView;
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        numDays = currentUser["Days"] as NSNumber!
        numMiles = currentUser["Miles"] as NSNumber!

        numRange1 = currentUser["MinAgeRange"] as NSNumber!
        numRange2 = currentUser["MaxAgeRange"] as NSNumber!
        
        self.updateSettingValues(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = cellIds[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell

        if(indexPath.row == 0){
            tV1 = cell.contentView.viewWithTag(1) as UITextField
            tV1.text = numDays.stringValue
        }else if(indexPath.row == 1){
            tV3 = cell.contentView.viewWithTag(3) as UITextField
            tV4 = cell.contentView.viewWithTag(4) as UITextField
            tV3.text = numRange1.stringValue
            tV4.text = numRange2.stringValue
//            tV2 = cell.contentView.viewWithTag(2) as UITextField
//            tV2.text = numMiles.stringValue
        }
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var flag :Bool = false
        var string = textField.text as NSString
        var minValue : Float
        var maxValue : Float;
        
        minValue = textField.tag == 1 ? 1 : 1
        maxValue = textField.tag == 1 ? 14 : 100
        let tValue = string.floatValue
        if(string != ""){
            
            if(tValue > maxValue || tValue < minValue){
                flag = false
            }else{
                flag = true
            }
        }
        
        if(flag == true){
            if(textField.tag == 1){
                if(tValue != numDays){
                    numDays = tValue
                    currentUser["Days"] = numDays
                    updateSettingValues(true)
                }
            }else{
                if(textField.tag == 3){
                    if(tValue != numRange1){
                        numRange1 = tValue
                        currentUser["MinAgeRange"] = numRange1
                    }
                }
                if(textField.tag == 4){
                    if(tValue != numRange2){
                        numRange2 = tValue
                        currentUser["MaxAgeRange"] = numRange2
                    }
                }
                updateSettingValues(true)
//                if(tValue != numMiles){
//                    numMiles = tValue
//                    currentUser["Miles"] = numMiles
//                    updateSettingValues(true)
//                }
            }

        }else{
            let alertView = UIAlertView(title: "Error", message: "Please enter correct values(\(minValue)-\(maxValue))", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        MBProgressHUD.hideHUDForView(self.view, animated: false)

    }
    
    func updateSettingValues(changed: Bool){
        var isChanged : Bool = changed
        if(numDays == nil || numDays.floatValue < 1 || numDays.floatValue > 14){
            numDays = NSNumber(float: 3)
            currentUser["Days"] = numDays
            isChanged = true
        }
        if(numMiles == nil || numMiles.floatValue < 0.2 || numDays.floatValue > 20){
            numMiles = NSNumber(float: 0.2)
            currentUser["Miles"] = numMiles
            isChanged = true
        }
        if(numRange1 == nil || numRange1.integerValue < 18 || numRange1.integerValue > 99){
            numRange1 = NSNumber(integer: 18)
            currentUser["MinAgeRange"] = numRange1
            isChanged = true
        }
        if(numRange2 == nil || (numRange2.integerValue < numRange1.integerValue) || numRange2.integerValue > 99){
            numRange2 = NSNumber(integer: 99)
            currentUser["MaxAgeRange"] = numRange2
            isChanged = true
        }
//        var tV1 = self.tableView.ce.viewWithTag(1) as UITextField
//        var tV2 = self.tableView.viewWithTag(2) as UITextField
        if(tV1 != nil){
            tV1.text = numDays.stringValue
        }
        if(tV2 != nil){
            tV2.text = numMiles.stringValue
        }
        if(tV3 != nil){
            tV3.text = numRange1.stringValue
            
        }
        if(tV4 != nil){
            tV4.text = numRange2.stringValue
        }
        
        if(isChanged == true){
            currentUser.save()
        }
    }
    
    func menuClicked(){
        NSLog("Menu Button Clicked!")
        
        self.revealViewController().revealToggleAnimated(true)
    }
    
}
