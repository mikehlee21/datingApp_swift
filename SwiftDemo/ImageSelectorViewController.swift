//
//  ImageSelectorViewController.swift
//  SwiftDemo
//
//  Created by Root on 19/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class ImageSelectorViewController: UIViewController, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var m_viewForInfo: UIView!
    @IBOutlet weak var m_lblInfoTitle: UILabel!
    @IBOutlet weak var m_txtInfoContent: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    var profilePictureView:FBProfilePictureView = FBProfilePictureView()
    var loginScreen:ViewController?

    var userName = ""
    var password = ""
    var emailID  = ""
    var dateOfBirth = ""
    var facebookLogin = false
    var selecteProfilePicture = UIImage()
    var user: FBGraphUser!
    var selectedImage:Bool  = false
    
    
    var arrInfoTitles = NSMutableArray(objects: "FROM", "CITY", "ABOUT", "WORK", "EDUCATION")
    var dicInfoContents = NSMutableDictionary()
    var indexForTitles = 0
    var originalCoord : CGPoint!

    @IBAction func btnSaveClicked(sender: AnyObject) {
        if(m_txtInfoContent.text == ""){
            let alertView = UIAlertView(title: "Error", message: "\(arrInfoTitles[indexForTitles]) could not be empty", delegate: nil, cancelButtonTitle: "Ok")
            return;
        }
        dicInfoContents[arrInfoTitles[indexForTitles] as NSString] = m_txtInfoContent.text
        self.nextTitle()
        
    }
    
    @IBAction func btnSkipClicked(sender: AnyObject) {
        
        self.nextTitle()
    }
    
    func nextTitle(){
        var centerPos = m_viewForInfo.center

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            centerPos.x = self.view.frame.size.width/2*3
            self.m_viewForInfo.center = centerPos
            
            }) { (finished: Bool) -> Void in
                if(finished == true){
                    self.indexForTitles = (self.indexForTitles + 1) % self.arrInfoTitles.count
                    self.m_lblInfoTitle.text = self.arrInfoTitles[self.indexForTitles] as NSString
                    var tmp = self.dicInfoContents[self.arrInfoTitles[self.indexForTitles] as NSString] as NSString!
                    if( tmp != nil){
                        self.m_txtInfoContent.text = tmp
                    }else{
                        self.m_txtInfoContent.text = ""
                    }
                    self.m_viewForInfo.center = centerPos

                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        if (user != nil) {
            var button1 = self.view.viewWithTag(1) as UIButton
            var button2 = self.view.viewWithTag(2) as UIButton
            
            let gender = user.objectForKey("gender") as String!
            if(gender == "female" || gender == "Female"){
                button1.selected = false
                button2.selected = true
            }else{
                button1.selected = true
                button2.selected = false
            }
            let str = NSString(format:"https://graph.facebook.com/%@/picture?type=large", user.id)
//            let url = NSURL.fileURLWithPath(str)
            let url = NSURL(string: str)
            var err: NSError? = NSError()
            var imageData = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)

            var bgImage = UIImage(data: imageData!)//UIImage(data:imageData)
            setProfileImage(bgImage!)
            
            //FROM, CITY, ABOUT, WORK, EDUCATION
//            FBGraphObject
            let hometown = user.objectForKey("hometown") as FBGraphObject!
            if(hometown != nil){
//                NSLog("\(hometown)")
                dicInfoContents["FROM"] = hometown.objectForKey("name")
                m_txtInfoContent.text = dicInfoContents["FROM"] as String
            }
            if(user.location != nil){
                NSLog("\(user.location)")
                dicInfoContents["CITY"] = user.location.name
                
            }
            let about = user.objectForKey("bio") as String!
            if(about != nil){
                NSLog("\(about)")
                dicInfoContents["ABOUT"] = about
            }
            
            let work = user.objectForKey("work") as [FBGraphObject]!
            if(work != nil){
                let obj = work[0]
                let position = obj.objectForKey("position") as FBGraphObject!
                let employer = obj.objectForKey("employer") as FBGraphObject!
                var strWork : String

                strWork = ""
                if(position != nil){
                    strWork = position.objectForKey("name") as String
                }
                if(employer != nil){
                    let tempStr = employer.objectForKey("name") as String
                    strWork = strWork + " at " + tempStr
                }
                dicInfoContents["WORK"] = "\(strWork)"
            }
            
            let education = user.objectForKey("education") as [FBGraphObject]!
            if(education != nil){
                let obj = education[0]
                let school = obj.objectForKey("school") as FBGraphObject!
                var strEducation = school.objectForKey("name") as String!
                if(strEducation != nil){
                    dicInfoContents["EDUCATION"] = "\(strEducation)"
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUserName(name:String, password:String, Email email:String, andDateOfBirth dob:String)
    {
        self.userName       = name
        self.emailID        = email
        self.password       = password
        self.dateOfBirth    = dob
        
        println(self.password)
    }
    
    @IBAction func signUpTapped(sender: UIButton)
    {
        if (checkMandatoryFieldsAreSet())
        {
            var user = PFUser()
            var tmp : NSString!
            user.username   = self.userName
            user.password   = self.password
            user.email      = self.emailID
            
            for cont in self.arrInfoTitles{
                tmp = self.dicInfoContents[cont as NSString] as NSString!
                if(tmp == nil){
                    user[cont as NSString] = ""
                }else{
                    user[cont as NSString] = tmp
                }
            }
           
            user["dobstring"] = self.dateOfBirth
            
            var button1 = self.view.viewWithTag(1) as UIButton
            var button2 = self.view.viewWithTag(2) as UIButton
            
            user["gender"] = button1.selected ? "male" : "female"
            
            button1 = self.view.viewWithTag(3) as UIButton
            button2 = self.view.viewWithTag(4) as UIButton
            
            user["interestedin"] = button1.selected ? "male" : "female"
            
            var location:CLLocation = CLLocation()
            
            location = GlobalVariableSharedInstance.currentLocation() as CLLocation
            
            let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as PFGeoPoint
            
            user["location"] = geoPoint
            
            if (facebookLogin == true)
            {
                user["fbID"] =  self.user.id
            }

            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            user.signUpInBackgroundWithBlock {
                
                (succeeded: Bool!, error: NSError!) -> Void in
                if !(error != nil)
                {
                    let imageName = self.userName + ".jpg" as String
                    
                    let userPhoto = PFObject(className: "UserPhoto")
                    
                    let imageData = UIImageJPEGRepresentation(self.selecteProfilePicture, 0.7)//(self.selecteProfilePicture)
                    
                    let imageFile = PFFile(name:imageName, data:imageData)
                    
                    userPhoto["imageFile"] = imageName
                    
                    userPhoto["Photos"] = [imageFile]
                    
                    userPhoto["userId"] = user.objectId
                    userPhoto["username"] = user.username
                    
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("cityCheckIn")
                    
                    userPhoto.saveInBackgroundWithBlock{
                        
                        (succeeded:Bool!, error:NSError!) -> Void in
                        
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                        if !(error != nil)
                        {
                            var messageBody = "Successfully Signed Up. Please login using your Email address and Password."
                            if (self.facebookLogin == true){
                                messageBody = "Successfully Signed Up."
                            }
                            var alert:UIAlertView = UIAlertView(title: "Welcome!", message: messageBody, delegate: self, cancelButtonTitle: "Ok")
                            
                            alert.show()
                        }
                        else
                        {
                            if let errorString = error.userInfo?["error"] as? NSString
                            {
                                println(errorString)
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                            else {
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Unable to signup.", delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                        }
                    }
                }
                else
                {
                            if let errorString = error.userInfo?["error"] as? NSString
                            {
                                println(errorString)
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                            else {
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Unable to signup.", delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                    MBProgressHUD.hideHUDForView(self.view, animated:false)                    
                }
            }
        }
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
                self.setProfileImage(originalImage);
            }
            
        })
        
    }

    func setProfileImage(originalImage: UIImage) {
        
        self.profilePicture.image = self.resizeImage(originalImage, toSize: CGSizeMake(134.0, 144.0))
        
        self.selecteProfilePicture = self.resizeImage(originalImage, toSize: CGSizeMake(134.0, 144.0))
        
        self.selectedImage  = true
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectedImage  = false
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        var username = self.userName
        var pwd = self.password
        
        PFUser.logInWithUsernameInBackground(username , password:pwd){
            (user: PFUser!, error: NSError!) -> Void in
            if (user != nil)
            {
                if (self.facebookLogin == true)
                {
                    self.navigationController!.popToRootViewControllerAnimated(true)
                    //self.dismissViewControllerAnimated(false, completion: nil)
                }
                else
                {
                    let loginScreen = self.navigationController!.viewControllers![0] as ViewController
                    loginScreen.facebookLogin   = true
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }
            }
            else
            {
                if let errorString = error.userInfo?["error"] as? NSString
                {
                    var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                    
                    alert.show()
                }
            }
        }
        
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
        
        if (self.selectedImage == false)
        {
            message = "Please select your profile picture"
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

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        if(originalCoord == nil){
            originalCoord = self.view.center
        }
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.view.center = CGPointMake(self.view.frame.width/2, 100)
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.view.center = self.originalCoord
        })
    }
}
