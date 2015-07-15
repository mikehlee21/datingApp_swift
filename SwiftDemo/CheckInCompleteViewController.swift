//
//  CheckInCompleteViewController.swift
//  TestApp2
//
//  Created by macos on 12/2/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit

class CheckInCompleteViewController: UITableViewController, RemoveCheckInPhotoDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_txtDescription: UITextView!
    var geoPoint : PFGeoPoint!
    var imgPhoto : UIImage!
    var txtDescription : String!
    var arrImages : NSMutableArray = []
    var coord : CLLocationCoordinate2D!
    var idxPath : NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Check In"
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("btnSaveClicked"))
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        m_txtDescription.layer.borderWidth = 1
        m_txtDescription.layer.cornerRadius = 3
        m_txtDescription.layer.borderColor = UIColor.grayColor().CGColor
        m_txtDescription.layer.masksToBounds = true
    }
    
    func btnSaveClicked(){
        
        
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        
        let user : PFUser = PFUser.currentUser()
        var obj : PFObject!
        var arrPhotos : NSMutableArray = []
        var count : NSInteger
        
        let query = PFQuery(className: "CheckedInData")
        query.whereKey("userId", equalTo: user.objectId)
        obj = query.getFirstObject()
        if(obj == nil){
            obj = PFObject(className: "CheckedInData")
        }
        obj.setObject(user.objectId, forKey: "userId")
        obj.setObject(user.username, forKey: "username")
        obj.setObject(user["dobstring"], forKey: "dobstring")
        obj.setObject(m_txtDescription.text, forKey: "Mood")
        obj.setObject(PFGeoPoint(latitude: coord.latitude, longitude: coord.longitude), forKey: "location")
        
        obj.setObject(user["gender"], forKey: "gender")
        obj.setObject(user["interestedin"], forKey: "interestedin")
        
        count = 0
        for image in arrImages{
            let imgData : NSData = UIImageJPEGRepresentation(image as UIImage, 0.7)
            var file : PFFile = PFFile(data: imgData)
            file.saveInBackgroundWithBlock { (success :Bool, error: NSError!) -> Void in
                if(error == nil){
                    arrPhotos.addObject(file)
                }
                count = count + 1
                NSLog("Count = \(count)")
                
                if( count == self.arrImages.count){
                    var success: Bool
                    
                    if(count == arrPhotos.count){
                        obj.setObject(arrPhotos, forKey: "Photos")
                        success = obj.save()
                        if(success == true){
                            user.setObject(obj.objectId, forKey: "LastCheckIn")
                            user.saveInBackground()
                        }
                        
                    }else{
                        success = false
                        
                    }
                    
                    
                    MBProgressHUD.showHUDAddedTo(self.view, animated:true)
                    
                    if(success == true){
                        let alertView = UIAlertView(title: "Success", message: "You just checked in new place!", delegate: nil, cancelButtonTitle: "Ok")
                        alertView.show()
                        
                        if(self.idxPath.row == 0){
                            NSUserDefaults.standardUserDefaults().setObject("true", forKey: "cityCheckIn")
                        }else{
                            NSUserDefaults.standardUserDefaults().setObject("false", forKey: "cityCheckIn")
                        }
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CheckedInSuccessful", object: nil))
                    }else{
                        let alertView = UIAlertView(title: "Error", message: "Check in was failed!\nPlease check your network again.", delegate: nil, cancelButtonTitle: "Ok")
                        alertView.show()
                    }
                }
            }
        }
        //routine same to above
        if(arrImages.count == 0){
            var success: Bool
            
            if(count == arrPhotos.count){
                obj.setObject(arrPhotos, forKey: "Photos")
                success = obj.save()
                if(success == true){
                    user.setObject(obj.objectId, forKey: "LastCheckIn")
                    user.saveInBackground()
                }
                
            }else{
                success = false
                
            }
            
            
            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            
            if(success == true){
                let alertView = UIAlertView(title: "Success", message: "You just checked in new place!", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
                
                if(self.idxPath.row == 0){
                    NSUserDefaults.standardUserDefaults().setObject("true", forKey: "cityCheckIn")
                }else{
                    NSUserDefaults.standardUserDefaults().setObject("false", forKey: "cityCheckIn")
                }
                NSUserDefaults.standardUserDefaults().synchronize()
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CheckedInSuccessful", object: nil))
            }else{
                let alertView = UIAlertView(title: "Error", message: "Check in was failed!\nPlease check your network again.", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        m_imgPhoto.image = imgPhoto
        m_txtDescription.text = txtDescription
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        m_imgPhoto.image = imgPhoto
        m_txtDescription.text = txtDescription
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImages.count + 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 44
        }else{
            return 300
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier: NSString
        
        if(indexPath.row > 0){
            
            cellIdentifier = "CheckInImageCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as CheckInImageCell
            cell.imageView?.image = arrImages[indexPath.row - 1] as? UIImage
            cell.imageView?.frame = CGRectMake(20, 10, 260, 280)
            cell.contentView.sendSubviewToBack(cell.imageView!)
            cell.indexPath = indexPath
            cell.delegate = self
            
            return cell
            
        }else{
            cellIdentifier = "AddPhotoButtonCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
            return cell
            
        }
    }
    
    func removePhotoAtIndexPath(indexPath: NSIndexPath) {
        arrImages.removeObjectAtIndex(indexPath.row-1)
        txtDescription = m_txtDescription.text
        self.tableView.reloadData()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            let actionSheet : UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Suggest Photo", "Take Photo")
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        NSLog("ActionSheet \(buttonIndex)")
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        if(buttonIndex == 1){ //Suggest Photo
            
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePickerController.allowsEditing = true
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }else if(buttonIndex == 2){ // Take Photo
            
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.allowsEditing = true
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        self.m_imgPlace.image = image
        arrImages.addObject(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        txtDescription = m_txtDescription.text
        self.tableView.reloadData()
    }
}
