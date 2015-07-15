//
//  SettingsViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate /*, UIAlertViewDelegate*/ {

    var pickerContainer = UIView()
    var picker = UIDatePicker()
    var updatedProfilePicture = false
    var selecteProfilePicture = UIImage()
    var titleImageView = UIImageView(image: UIImage(named: "30.png"))
    var objUserPhoto : PFObject!
    var arrPhotos: NSMutableArray = []
    var arrNewPhotos: NSMutableArray = []
    
    @IBOutlet weak var m_pageControl: UIPageControl!
    @IBOutlet weak var m_pageScrollView: UIScrollView!
    
    
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    
    @IBOutlet weak var textfieldUserName: UITextField!
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var buttonDateOfBirth: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.updateUI()
        self.fillUserDetails()
        self.configurePicker()
        
        updatedProfilePicture = false
    }
    
    func menuClicked(){
        NSLog("Menu Button Clicked!")
        
        self.revealViewController().revealToggleAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollViewContainer.contentSize    = CGSizeMake(320.0, 750.0)
    }

    func updateUI()
    {
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        
        self.m_pageControl.userInteractionEnabled = false
        var frame = self.view.frame
        
//        frame   = self.scrollViewContainer.frame
//        frame.size.height   = 200
        
//        self.scrollViewContainer.frame  = CGRectMake(0.0, self.scrollViewContainer.frame.origin.y, 320.0, 447.0)
        
        self.scrollViewContainer.contentSize    = CGSizeMake(320.0, 750.0)
//        self.scrollViewContainer.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        self.view.addGestureRecognizer( self.revealViewController().panGestureRecognizer())
        
        let menuImageView = UIImageView(image: UIImage(named: "Menu30.png"))
        let leftBarButton = UIBarButtonItem(image: menuImageView.image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("menuClicked"))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.navigationItem.titleView = titleImageView;
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        
    }
    
    func fillUserDetails()
    {
        let user = PFUser.currentUser() as PFUser
        
        self.textfieldUserName.text = user.username
        self.textfieldEmailAddress.text = user.email
        self.textfieldPassword.text = user.password
        NSLog("\(user.username): \(user.email): \(user.password)")
        
        let dob = user["dobstring"] as String
        
        self.buttonDateOfBirth.setTitle(dob, forState: UIControlState.Normal)

        let gender = user["gender"] as String
        
        var button1 = self.view.viewWithTag(1) as UIButton
        var button2 = self.view.viewWithTag(2) as UIButton
        
        if (gender == "male")
        {
            button1.selected    = true
            button2.selected    = false
        }
        else
        {
            button1.selected    = false
            button2.selected    = true
        }
        
        let interestedIn = user["interestedin"] as String
        
        button1 = self.view.viewWithTag(3) as UIButton
        button2 = self.view.viewWithTag(4) as UIButton
        
        if (interestedIn == "male")
        {
            button1.selected    = true
            button2.selected    = false
        }
        else
        {
            button1.selected    = false
            button2.selected    = true
        }
        
        var query = PFQuery(className: "UserPhoto")
        query.whereKey("userId", equalTo: user.objectId)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            
            if(object != nil)
            {
                
                self.objUserPhoto = object
                self.arrPhotos = object["Photos"] as NSMutableArray;
                self.reloadScrollView()

            }
            MBProgressHUD.hideHUDForView(self.view, animated:false)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseProfilePicture(sender: UIButton)
    {
        let myActionSheet = UIActionSheet()
        myActionSheet.delegate = self
        
        myActionSheet.addButtonWithTitle("Camera")
        myActionSheet.addButtonWithTitle("Photo Library")
        myActionSheet.addButtonWithTitle("Cancel")
        myActionSheet.cancelButtonIndex = 2
        
        myActionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
    {
        var sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        if (buttonIndex == 0)
        {
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) //Camera not available
            {
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            
            self.displayImagepicker(sourceType)
        }
        else if (buttonIndex == 1)
        {
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.displayImagepicker(sourceType)
        }
    }
    
    func displayImagepicker(sourceType:UIImagePickerControllerSourceType)
    {
        var imagePicker:UIImagePickerController = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        
        self.dismissViewControllerAnimated(true, completion: {
            
            var mediatype:NSString = info[UIImagePickerControllerMediaType]! as NSString
            
            if (mediatype == "public.image")
            {
                let originalImage = info[UIImagePickerControllerOriginalImage] as UIImage
                
                print("%@",originalImage.size)
                self.arrNewPhotos.insertObject(self.resizeImage(originalImage, toSize: CGSizeMake(134.0, 144.0)), atIndex: 0)
                self.reloadScrollView()
//
                self.updatedProfilePicture = true
            }
            
            })
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

//    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
//    {
//        if (alertView.tag == 10)
//        {
//            if(buttonIndex == 1)
//            {
//                FBSession.activeSession().closeAndClearTokenInformation()
//                let user = PFUser.currentUser() as PFUser
//                PFUser.logOut()
//                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                
//                delegate.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("InitialNavigationController") as? UIViewController
//            }
//        }
//        else
//        {
//            self.navigationController!.popToRootViewControllerAnimated(true)
//        }
//        
//    }
    
    
    @IBAction func changeDateOfBirth(sender: AnyObject)
    {
        self.textfieldUserName.resignFirstResponder()
        self.textfieldEmailAddress.resignFirstResponder()
        self.textfieldPassword.resignFirstResponder()
        
        
        UIView.animateWithDuration(0.4, animations: {
            
            var frame:CGRect = self.pickerContainer.frame
            frame.origin.y = self.view.frame.size.height - 300.0 + 40
            self.pickerContainer.frame = frame
            
            })
    }
    
    @IBAction func selectGender(sender: UIButton)
    {
        if (sender.tag == 1)
        {
            sender.selected = true
            
            let female = self.view.viewWithTag(2) as UIButton
            
            female.selected = false
        }
        else if (sender.tag == 2)
        {
            sender.selected = true
            
            let male = self.view.viewWithTag(1) as UIButton
            
            male.selected = false
        }
    }
    
    @IBAction func interestedIn(sender: UIButton)
    {
        if (sender.tag == 3)
        {
            sender.selected = true
            
            let female = self.view.viewWithTag(4) as UIButton
            
            female.selected = false
        }
        else if (sender.tag == 4)
        {
            sender.selected = true
            
            let male = self.view.viewWithTag(3) as UIButton
            
            male.selected = false
        }
    }


    @IBAction func updateMyProfile(sender : UIButton)
    {
        if (checkMandatoryFieldsAreSet())
        {
            sender.enabled  = false
            
            var user = PFUser.currentUser()
            user.username   = self.textfieldUserName.text
            if(self.textfieldPassword.text != ""){
                user.password   = self.textfieldPassword.text
            }
            user.email      = self.textfieldEmailAddress.text
            
            let dateOfBirth = self.buttonDateOfBirth.titleForState(UIControlState.Normal)
            user["dobstring"] = dateOfBirth
            
            var button1 = self.view.viewWithTag(1) as UIButton
            var button2 = self.view.viewWithTag(2) as UIButton
            
            user["gender"] = button1.selected ? "male" : "female"
            
            button1 = self.view.viewWithTag(3) as UIButton
            button2 = self.view.viewWithTag(4) as UIButton
            
            user["interestedin"] = button1.selected ? "male" : "female"
            
            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            user.saveInBackgroundWithBlock(
            {
                (BOOL succeeded, NSError error) -> Void in
                
                if (error == nil)
                {

                    if (self.updatedProfilePicture)
                    {
                        let imageName = self.textfieldUserName.text + ".jpg" as String
                        if(self.arrNewPhotos.count != 0){
                            for img in self.arrNewPhotos{
                                let imageData = UIImageJPEGRepresentation(img as UIImage, 0.7)
                                let imageFile = PFFile(name: imageName, data: imageData)
                                self.arrPhotos.insertObject(imageFile, atIndex: 0)
                            }
                        }
                        self.arrNewPhotos.removeAllObjects()
                        
                        if(self.m_pageControl.currentPage != 0){
                            let imageFile = self.arrPhotos[0] as PFFile
                            self.arrPhotos.replaceObjectAtIndex(0, withObject: self.arrPhotos[self.m_pageControl.currentPage])
                            self.arrPhotos.replaceObjectAtIndex(self.m_pageControl.currentPage, withObject: imageFile)
                        }

                    

                        self.objUserPhoto["Photos"] = self.arrPhotos
                        
                    
                        self.objUserPhoto.saveInBackgroundWithBlock{
                        
                        (succeeded:Bool!, error:NSError!) -> Void in
                        
                        if (error != nil)
                        {

                            
                        }
                        else
                        {
                            var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully updated profile.", delegate: nil, cancelButtonTitle: "Ok")
                            
                            alert.show()
                            
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ProfileChanged", object: nil))
                            self.reloadScrollView()
                        }

                        sender.enabled  = true
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                    }
                    
                    self.updatedProfilePicture = false
                    }
                    else
                    {
                        var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully updated profile.", delegate: nil, cancelButtonTitle: "Ok")
                            
                        alert.show()

                        sender.enabled  = true
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                    }
                    
                }
                
            })

            }
        
    }
    
    @IBAction func logOutUser(sender: AnyObject)
    {

//        var alert:UIAlertView = UIAlertView(title: "Message", message: "Are you sure want to logout", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
//            
//        alert.tag = 10
//
//        alert.show()
        NSLog("%@", "loool")
    }
    
    
    func configurePicker()
    {
        pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
        pickerContainer.backgroundColor = UIColor.whiteColor()
        
        picker.frame    = CGRectMake(0.0, 20.0, 320.0, 300.0)
        picker.setDate(NSDate(), animated: true)
        picker.maximumDate = NSDate()
        picker.datePickerMode = UIDatePickerMode.Date
        pickerContainer.addSubview(picker)
        
        var doneButton = UIButton()
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: Selector("dismissPicker"), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.frame    = CGRectMake(250.0, 5.0, 70.0, 37.0)
        
        pickerContainer.addSubview(doneButton)
        
        self.view.addSubview(pickerContainer)
    }
    
    func dismissPicker ()
    {
        UIView.animateWithDuration(0.4, animations: {
            
            self.pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            self.buttonDateOfBirth.setTitle(dateFormatter.stringFromDate(self.picker.date), forState: UIControlState.Normal)
            })
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func checkMandatoryFieldsAreSet() -> Bool
    {
        var allFieldsAreSet = true
        
        var message = ""
        
        var button1 = self.view.viewWithTag(1) as UIButton
        var button2 = self.view.viewWithTag(2) as UIButton
        
        if (!button1.selected && !button2.selected)
        {
            message = "Please select your gender"
        }
        
        button1 = self.view.viewWithTag(3) as UIButton
        button2 = self.view.viewWithTag(4) as UIButton
        
        if (!button1.selected && !button2.selected)
        {
            message = "Please select whether you are interested in girls or boys"
        }
        
        if (message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0)
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
            
            allFieldsAreSet = false
        }
        
        return allFieldsAreSet
    }

    func resizeImage(original : UIImage, toSize size:CGSize) -> UIImage
    {
        var imageSize:CGSize = CGSizeZero
        
        if (original.size.width < original.size.height)
        {
            imageSize.height    = size.width * original.size.height / original.size.width
            imageSize.width     = size.width
        }
        else
        {
            imageSize.height    = size.height
            imageSize.width     = size.height * original.size.width / original.size.height
        }
        
        UIGraphicsBeginImageContext(imageSize)
        original.drawInRect(CGRectMake(0,0,imageSize.width,imageSize.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    //386
    //460
    //564
    
    @IBAction func btnRemovePhotoClicked(sender: AnyObject) {
        if(self.m_pageControl.numberOfPages == 1){
            return;
        }
        let count = self.arrNewPhotos.count
        if(self.m_pageControl.currentPage < count){
            self.arrNewPhotos.removeObjectAtIndex(self.m_pageControl.currentPage)
            
        }else{
            self.arrPhotos.removeObjectAtIndex(self.m_pageControl.currentPage - count)
        }
        self.updatedProfilePicture = true
        self.reloadScrollView()
    }
    
    func reloadScrollView(){
        var i : NSInteger
        i = 0
        
        for sV in self.m_pageScrollView.subviews{
            sV.removeFromSuperview()
        }
        for obj in self.arrNewPhotos{
            let image               = obj as UIImage
            
            var frame : CGRect
            frame = self.m_pageScrollView.frame
            frame.origin.x = frame.size.width * CGFloat(i)
            frame.origin.y = 0
            
            let imgView = UIImageView(image: image)
            imgView.frame = frame
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("chooseProfileImage:")))
            imgView.userInteractionEnabled = true
            imgView.layer.cornerRadius = imgView.frame.size.width/2
            imgView.layer.borderWidth = 1
            imgView.layer.borderColor = UIColor.lightGrayColor().CGColor
            imgView.layer.masksToBounds = true
            
            self.m_pageScrollView.addSubview(imgView)
            i = i + 1
        }
        for obj in self.arrPhotos{
            let imageData:NSData    = obj.getData()
            let image               = UIImage(data: imageData)
            
            var frame : CGRect
            frame = self.m_pageScrollView.frame
            frame.origin.x = frame.size.width * CGFloat(i)
            frame.origin.y = 0
            
            let imgView = UIImageView(image: image)
            imgView.frame = frame
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("chooseProfileImage:")))
            imgView.userInteractionEnabled = true
            imgView.layer.cornerRadius = imgView.frame.size.width/2
            imgView.layer.borderWidth = 1
            imgView.layer.borderColor = UIColor.lightGrayColor().CGColor
            imgView.layer.masksToBounds = true
            
            self.m_pageScrollView.addSubview(imgView)
            i = i + 1
        }
        self.m_pageScrollView.contentSize = CGSizeMake( self.m_pageScrollView.frame.size.width * CGFloat(i), self.m_pageScrollView.frame.size.height)
        self.m_pageScrollView.pagingEnabled = true
        self.m_pageControl.numberOfPages = i
        self.m_pageControl.currentPage = 0
        self.m_pageScrollView.contentOffset.x = 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.m_pageScrollView.frame.size.width
        let page = floor((self.m_pageScrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1
        self.m_pageControl.currentPage = NSInteger(page)
        self.updatedProfilePicture = true
    }
    @IBAction func pageNumberChanged(sender: UIPageControl) {
        let pageWidth = self.m_pageScrollView.frame.size.width
        self.m_pageScrollView.contentOffset.x = pageWidth * CGFloat(sender.currentPage)
        self.updatedProfilePicture = true
    }
    
    func chooseProfileImage(gest:UIGestureRecognizer){
        let myActionSheet = UIActionSheet()
        myActionSheet.delegate = self
        
        myActionSheet.addButtonWithTitle("Camera")
        myActionSheet.addButtonWithTitle("Photo Library")
        myActionSheet.addButtonWithTitle("Cancel")
        myActionSheet.cancelButtonIndex = 2
        
        myActionSheet.showInView(self.view)
    }
}
