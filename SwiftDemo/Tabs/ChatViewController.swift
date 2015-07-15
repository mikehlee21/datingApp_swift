//
//  ChatViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var arrayUserIds:Array<String> = []
    var dicUserDatas:NSMutableDictionary!

    var arrayUserFriends:NSMutableArray = []
    var arrayPhotoObjects:Array<PFObject> = []
    
    let currentUser = PFUser.currentUser()
    
    @IBOutlet weak var chatTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        self.dicUserDatas = NSMutableDictionary()
        fetchFriends()
        
        self.title = "Matched Users"
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refresh:")) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = barButton
        
        let menuImageView = UIImageView(image: UIImage(named: "Menu30.png"))
        let leftBarButton = UIBarButtonItem(image: menuImageView.image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("menuClicked"))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.view.addGestureRecognizer( self.revealViewController().panGestureRecognizer())
    }

    func menuClicked(){
        NSLog("Menu Button Clicked!")
        
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func refresh(button : UIBarButtonItem)
    {
        self.dicUserDatas.removeAllObjects()
        self.arrayUserIds.removeAll(keepCapacity: false)
        self.chatTable.reloadData()
        fetchFriends()
    }
    
    func fetchFriends()
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)

        var queryForLikedUsers = PFQuery(className:"MatchedUsers")
        
        queryForLikedUsers.whereKey("userId", equalTo: currentUser.objectId)
        let obj = queryForLikedUsers.getFirstObject()
        if(obj == nil){
            MBProgressHUD.hideHUDForView(self.view, animated: false)
            return
        }
        let arrLikedUsers = obj["matchedUsers"] as Array<String>
        
        let query = PFQuery(className: "MatchedUsers")
        query.whereKey("userId", containedIn: arrLikedUsers)
        query.whereKey("matchedUsers", containsAllObjectsInArray: [currentUser.objectId])
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            self.arrayUserIds.removeAll(keepCapacity: false)
            if(error == nil){
                for object in objects{
                    self.arrayUserIds.append(object["userId"] as String)
                }

                var query = PFQuery(className: "UserPhoto")
                query.whereKey("userId", containedIn: self.arrayUserIds)
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if(error == nil){
                        if(objects.count != 0)
                        {
                            self.arrayPhotoObjects = objects as Array
                            for object in objects{
                                self.dicUserDatas[object["userId"] as String] = object
                            }
                            self.chatTable.reloadData()
                        }
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: false)
                })
            }else{
                MBProgressHUD.hideHUDForView(self.view, animated: false)
            }
            
        }
    }
    
    func getUserFromUserId(userID:String, arrayUsers:NSArray) -> PFUser
    {
        var requiredUser = PFUser()
        
        for aUser in arrayUsers
        {
            if (aUser.objectId == userID)
            {
                requiredUser = aUser as PFUser
                break
            }
        }
        
        return requiredUser
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayUserIds.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let userId = self.arrayUserIds[indexPath.row]
        let object = self.dicUserDatas[userId] as PFObject
        let file = (object["Photos"]).objectAtIndex(0) as PFFile

        cell.imageView?.image = UIImage(named: "noMatchFound.png")
        cell.imageView?.frame = CGRectMake(5, 5, 44, 44)
        file.getDataInBackgroundWithBlock { (data: NSData!, error: NSError!) -> Void in
            cell.imageView?.image = UIImage(data: data)
            cell.imageView?.frame = CGRectMake(5, 5, 44, 44)
        }
        
        cell.textLabel?.text = object["username"] as? String

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let buttonRemove = UIButton.buttonWithType(UIButtonType.System) as UIButton
        buttonRemove.setTitle("X", forState: UIControlState.Normal)
        buttonRemove.addTarget(self, action: Selector("btnRemoveClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        buttonRemove.tag = indexPath.row
        var rect = cell.bounds
        rect.origin.x = rect.size.width - 44
        rect.size.width = 44
        buttonRemove.frame = rect
        cell.contentView.addSubview(buttonRemove)
        return cell
    }
    
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        return 54.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ChatViewControllerSegue" ){
            let indexPath :NSIndexPath = self.chatTable.indexPathForSelectedRow()!
            let userId = self.arrayUserIds[indexPath.row]
            let destination = segue.destinationViewController as MessageViewController
            destination.receiverUserId = userId

        }
    }

    
    @IBAction func btnRemoveClicked(sender: AnyObject) {
        let indexRow: NSInteger = sender.tag
        
        let userId = self.arrayUserIds[indexRow]
        self.dicUserDatas.removeObjectForKey(userId)
        self.arrayUserIds.removeAtIndex(indexRow)
        
        
        var queryForLikedUsers = PFQuery(className:"MatchedUsers")
        
        queryForLikedUsers.whereKey("userId", equalTo: currentUser.objectId)
        let obj = queryForLikedUsers.getFirstObject()
        obj["matchedUsers"].removeObject(userId)
        obj.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            let alertView = UIAlertView(title: "Success", message: "Successfully removed!", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
//        let arrLikedUsers = obj["matchedUsers"] as Array<String>
        
        
        self.chatTable.reloadData()
    }
    
}
