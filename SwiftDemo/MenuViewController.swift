//
//  MenuViewController.swift
//  TestApp2
//
//  Created by macos on 11/6/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController, UIAlertViewDelegate {
    let menuStr : Array<String> = ["CheckIn", "Home", "Profile", "Matches", "Settings", "Logout"]
    
    @IBOutlet weak var m_userPhoto: UIImageView!
    @IBOutlet weak var m_username: UILabel!

    var curViewController : UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("profileChanged:"), name: "ProfileChanged", object: nil)
//                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CheckedInSuccessful", object: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkedInSuccessful:"), name: "CheckedInSuccessful", object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        let currentUser = PFUser.currentUser()
        
        m_username.text = currentUser.username
        m_userPhoto.layer.cornerRadius = m_userPhoto.frame.size.width/2
        m_userPhoto.layer.borderWidth = 1.5
        m_userPhoto.layer.borderColor = UIColor.grayColor().CGColor
        m_userPhoto.layer.masksToBounds = true
        
        self.profileChanged(nil)
    }
    
    func checkedInSuccessful(notification: NSNotification){
//        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
//        self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        self.performSegueWithIdentifier("MainViewSegueIdentifier", sender: self)
        NSLog("CAlled")
    }
    
    func profileChanged(notification:NSNotification!){
        let currentUser = PFUser.currentUser()
        let query = PFQuery(className: "UserPhoto")
        query.whereKey("userId", equalTo: currentUser.objectId)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if(error == nil){
                let file = (object["Photos"]).objectAtIndex(0) as PFFile
                file.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
                    if(error == nil){
                        self.m_userPhoto.image = UIImage(data: data)
                    }
                })
            }
        }
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
        return menuStr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = String("menuItem\(menuStr[indexPath.row])")
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as MenuCell

        // Configure the cell...
        cell.configureCell(menuStr[indexPath.row])
        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 5){
            var alert:UIAlertView = UIAlertView(title: "Message", message: "Are you sure want to logout", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
            
            alert.tag = 10
            
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.tag == 10)
        {
            if(buttonIndex == 1)
            {
                FBSession.activeSession().closeAndClearTokenInformation()
                let user = PFUser.currentUser() as PFUser
                PFUser.logOut()
                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

//                NSUserDefaults.standardUserDefaults().removeObjectForKey("cityCheckIn")
                delegate.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("InitialNavigationController") as? UIViewController
            }
        }
    }
    
    func isNilOrEmpty(string: NSString?) -> Bool {
        switch string {
        case .Some(let nonNilString): return nonNilString.length == 0
        default:                      return true
        }
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

    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let user = PFUser.currentUser()
        let isCheckIn = user["LastCheckIn"] as String?
        if isNilOrEmpty(isCheckIn){
            self.revealViewController().revealToggleAnimated(true)
            let alertView = UIAlertView(title: "Error", message: "You should check in at least one time.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return false
        }else{
            return true
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        if (segue.isKindOfClass(SlideViewControllerSegue.self)){
            curViewController = nil
            
            let svSegue = segue as SlideViewControllerSegue
//            { (parameters) -> return type in
//                statements
//            }
            svSegue.performBlock = {
                (rvc_segue: SlideViewControllerSegue!, svc:UIViewController!, dvc:UIViewController!) -> Void in
                self.curViewController = dvc
                let navController = self.revealViewController().frontViewController as UINavigationController
                
                navController.setViewControllers([dvc], animated: false)
                self.revealViewController().setFrontViewPosition(FrontViewPositionLeft, animated: true)
            }
        }
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

class MenuCell : UITableViewCell {
    
    @IBOutlet weak var m_lblMenuItem: UILabel!
    func configureCell(menuItem:NSString){
        m_lblMenuItem.text = menuItem;
    }
}
