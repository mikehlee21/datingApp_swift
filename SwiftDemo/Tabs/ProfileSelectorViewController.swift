//
//  ProfileSelectorViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//


import UIKit
import CoreGraphics
import MessageUI


class ProfileSelectorViewController: UIViewController, InfoViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {

//    @IBOutlet var borderView : UIView?
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var m_txtDiscardChange: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var m_txtLikeChange: UITextField!
    @IBOutlet weak var m_lblNameAge: UILabel!
    @IBOutlet weak var m_lblCountOfPhotos: UILabel!
    @IBOutlet weak var m_lblCheckInDays: UILabel!
    @IBOutlet weak var m_imgNoMatched: UIImageView!
    
    @IBOutlet weak var m_btnInfo: UIButton!
    @IBOutlet weak var m_btnPrevious: UIButton!
    @IBOutlet weak var m_btnRefresh: UIButton!
    @IBOutlet weak var m_btnChange: UIButton!

    var numAgeMin : NSNumber!
    var numAgeMax : NSNumber!
    let user = PFUser.currentUser()
    var lastUpdatedCoord : PFGeoPoint!
    var changeButtonTitle = "Change"
    var arrayCheckins:NSMutableArray = []
    
    var arrayProfilesConsidered = []
    var arrayDraggableViews:NSMutableArray = []
    
    var arrayLikedUsers:Array<NSString> = []
//    var arrayLikedMoreUsers:Array<NSString> = []
    var objLikedUsers:PFObject!
    
    var curIndexOfCheckin : NSInteger!

    func updateSettingValues(){
        var isChanged = false
        var currentUser = PFUser.currentUser()
        var numDays = currentUser["Days"] as NSNumber!
        var numMiles = currentUser["Miles"] as NSNumber!
        numAgeMin = currentUser["MinAgeRange"] as NSNumber!
        numAgeMax = currentUser["MaxAgeRange"] as NSNumber!
        
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
        
        if(numAgeMin == nil || numAgeMin.integerValue < 18 || numAgeMin.integerValue > 99){
            numAgeMin = NSNumber(integer: 18)
            currentUser["MinAgeRange"] = numAgeMin;
            isChanged = true;
        }
        
        if(numAgeMax == nil || numAgeMax.integerValue < numAgeMin.integerValue || numAgeMax.integerValue > 99){
            numAgeMax = NSNumber(integer: 99)
            currentUser["MaxAgeRange"] = numAgeMax
            isChanged = true
        }
        
        //        var tV1 = self.tableView.ce.viewWithTag(1) as UITextField
        //        var tV2 = self.tableView.viewWithTag(2) as UITextField
        if(isChanged == true){
            currentUser.save()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "CheckedInData")
        query.whereKey("objectId", equalTo: user["LastCheckIn"])
        let lastCheckInObj = query.getFirstObject()
        lastUpdatedCoord = lastCheckInObj["location"] as PFGeoPoint
        
        self.updateSettingValues()
        
        var likeButtonTitle = NSUserDefaults.standardUserDefaults().objectForKey("LikeButtonTitle") as String!
        var discardButtonTitle = NSUserDefaults.standardUserDefaults().objectForKey("DiscardButtonTitle") as String!
        
        if let lbt = likeButtonTitle{

        }else{
            NSUserDefaults.standardUserDefaults().setObject("√", forKey: "LikeButtonTitle")
            NSUserDefaults.standardUserDefaults().setObject("X", forKey: "DiscardButtonTitle")
            NSUserDefaults.standardUserDefaults().synchronize()
            likeButtonTitle = "√"
            discardButtonTitle = "X"
        }
        
        self.likeButton.setTitle(likeButtonTitle, forState: UIControlState.Normal)
        self.discardButton.setTitle(discardButtonTitle, forState: UIControlState.Normal)
        
        self.updateUI()

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("getLikedUsers"), userInfo: nil, repeats: false)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: "UIKeyboardWillShowNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: "UIKeyboardWillHideNotification", object: nil)

        m_imgNoMatched.layer.cornerRadius = m_imgNoMatched.frame.size.width/2.0
        m_imgNoMatched.layer.borderWidth = 1
        m_imgNoMatched.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(note: NSNotification){
        let userInfo : Dictionary = note.userInfo!
        let kbSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size as CGSize!
        NSLog("Keyboard Height: \(kbSize?.height)")
        
        var frame = self.view.frame
        frame.origin.y = -kbSize.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = frame
        })
    }
    
    func keyboardDidHide(note: NSNotification){
        var frame = self.view.frame
        frame.origin.y = 0
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = frame
        })
    }

    func updateUI()
    {
        
        changeButtonTitle = "Change"
        self.m_btnChange.setTitle(changeButtonTitle, forState: UIControlState.Normal)
        
        self.discardButton!.layer.cornerRadius  = self.discardButton.frame.size.width / 2.0
        self.likeButton.layer.cornerRadius      = self.likeButton.frame.size.width / 2.0
        
        self.m_btnInfo.layer.cornerRadius = 5
        self.m_btnPrevious.layer.cornerRadius = 5
        self.m_btnRefresh.layer.cornerRadius = 5
        
        self.m_btnInfo.layer.shadowOpacity = 0.5
        self.m_btnInfo.layer.shadowRadius = 1.0
        self.m_btnInfo.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.m_btnPrevious.layer.shadowOpacity = 0.5
        self.m_btnPrevious.layer.shadowRadius = 1.0
        self.m_btnPrevious.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.m_btnRefresh.layer.shadowOpacity = 0.5
        self.m_btnRefresh.layer.shadowRadius = 1.0
        self.m_btnRefresh.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.likeButton.layer.shadowOpacity = 0.5
        self.likeButton.layer.shadowRadius = 1.0
        self.likeButton.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.m_txtLikeChange.layer.shadowOpacity = 0.5
        self.m_txtLikeChange.layer.shadowRadius = 1.0
        self.m_txtLikeChange.layer.shadowOffset = CGSizeMake(-1, 2)
        self.m_txtLikeChange.layer.cornerRadius      = self.m_txtLikeChange.frame.size.width / 2.0
        
        
        self.discardButton.layer.shadowOpacity = 0.5
        self.discardButton.layer.shadowRadius = 1.0
        self.discardButton.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.m_txtDiscardChange.layer.shadowOpacity = 0.5
        self.m_txtDiscardChange.layer.shadowRadius = 1.0
        self.m_txtDiscardChange.layer.shadowOffset = CGSizeMake(-1, 2)
        self.m_txtDiscardChange.layer.cornerRadius  = self.m_txtDiscardChange.frame.size.width / 2.0
        
        self.m_txtLikeChange.hidden = true
        self.m_txtDiscardChange.hidden = true
        
//        self.enableLikeButtons(false)
        
//        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refresh:")) as UIBarButtonItem
//        self.navigationItem.rightBarButtonItem = barButton
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let titleImageView = UIImageView(image: UIImage(named: "30.png"))
        self.navigationItem.titleView = titleImageView;
        
        let rightBarButton = UIBarButtonItem(title: "Report", style: UIBarButtonItemStyle.Bordered,  target: self, action: Selector("more:")) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButton
//        Menu30
        let menuImageView = UIImageView(image: UIImage(named: "Menu30.png"))
        let leftBarButton = UIBarButtonItem(image: menuImageView.image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("menuClicked"))
        self.navigationItem.leftBarButtonItem = leftBarButton

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.view.addGestureRecognizer( self.revealViewController().panGestureRecognizer())

        
    }
    
    func menuClicked(){
        NSLog("Menu Button Clicked!")

        self.revealViewController().revealToggleAnimated(true)
    }

    func more(button : UIBarButtonItem)
    {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Report this user")
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        
        case 0:
            NSLog("click here!")
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            break
        case 1:
            break
        default:
            break
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["ericmgeller@gmail.com"])
        mailComposerVC.setSubject("Report this user")
        var mystring: String = self.m_lblNameAge.text!
        var selectedNameAry = mystring.componentsSeparatedByString(",")
        var selectedUserName: String = selectedNameAry[0]
        mailComposerVC.setMessageBody("Username:\(selectedUserName)", isHTML: true)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    ///////////////////////////////////
    func getRidOffDatas(objects: NSArray!){
        self.arrayCheckins.removeAllObjects()
        for object in objects{
            
            let dobString = object["dobstring"] as NSString!
            if(dobString != nil){
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat    = "MM/dd/yyyy"
                
                var date    = dateFormatter.dateFromString(dobString)! as NSDate
                var timeInterval    = date.timeIntervalSinceNow
                
                let age = Int(abs(timeInterval / (60 * 60 * 24 * 365))) as Int
                
                if(age >= numAgeMin.integerValue && age <= numAgeMax.integerValue){
                    self.arrayCheckins.addObject(object)
                }
            }

        }
        if(self.arrayCheckins.count == 0){
            var query2  = PFQuery(className: "CheckedInData")
            query2.whereKey("username", hasPrefix: "tester")
            query2.whereKey("gender", equalTo: self.user["interestedin"])
            query2.whereKey("userId", notEqualTo: self.user.objectId)
            
            var objects = query2.findObjects() as NSArray!
            for object in objects{
                if(contains(self.arrayLikedUsers, object["userId"] as String) == false){
                    self.arrayCheckins.addObject(object)
                }

            }
        }
        //        if(self.arrayCheckins.count == 0){
        //            var query2  = PFQuery(className: "CheckedInData")
        //            query2.whereKey("username", hasPrefix: "tester")
        //            query2.whereKey("gender", equalTo: user["interestedin"])
        //            query2.whereKey("userId", notEqualTo: user.objectId)
        //
        //            var objects = query2.findObjects() as NSArray!
        //            for object in objects{
        //                self.arrayCheckins.addObject(object)
        //            }
        //        }
    }
    
    func fetchMatches()
    {

        
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)

        var query = PFQuery(className: "CheckedInData")
        let days = -Int(user["Days"].floatValue) * 24 * 3600
        var checkinDate = NSDate(timeIntervalSinceNow: NSTimeInterval(days))
        var checkinMiles = Double(user["Miles"] as NSNumber)

        var isCityCheckedIn = NSUserDefaults.standardUserDefaults().objectForKey("cityCheckIn") as NSString!
        if((isCityCheckedIn == nil) || (isCityCheckedIn.isEqualToString("false") == true)){
            
            checkinMiles = 0.2
        }else{
            checkinMiles = 30
        }
        checkinMiles = 30
        
        NSLog("Miles = \(checkinMiles)")
        
        query.whereKey("updatedAt", greaterThan: checkinDate)
        query.whereKey("location", nearGeoPoint: lastUpdatedCoord, withinMiles: checkinMiles)
        query.whereKey("gender", equalTo: user["interestedin"])
        query.whereKey("userId", notEqualTo: user.objectId)
        query.whereKey("userId", notContainedIn: self.arrayLikedUsers)
        
        query.findObjectsInBackgroundWithBlock { (objects :[AnyObject]!, error :NSError!) -> Void in
            NSLog("Count = \(objects.count)")
            if(objects == nil){
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                return;
            }
            
//            self.arrayCheckins = NSMutableArray(array: objects)
            
            
            self.getRidOffDatas(objects)

            let count : NSInteger = self.arrayCheckins.count - 1

            self.curIndexOfCheckin = count
            if(count < 0){
                MBProgressHUD.hideHUDForView(self.view, animated: false)
                return;
            }
            
            for index in 0...count{
//                var k = index % 5

                let rt = self.m_imgNoMatched.frame
//                rt.origin.y = rt.origin.y + CGFloat(k)
//                rt.origin.x = rt.origin.x + CGFloat(k)
                
                var viewDraggable = DraggableView(frame: /*CGRectMake(13.0 , 74.0 + CGFloat(k), 295.0, 190.0)*/rt, delegate: self) as DraggableView
                viewDraggable.setUser(self.arrayCheckins[index] as PFObject)
                viewDraggable.update(self.arrayCheckins[index] as PFObject)
                self.view.addSubview(viewDraggable)
                viewDraggable.tag = index + 100
                self.arrayDraggableViews.addObject(viewDraggable)
            }
            MBProgressHUD.hideHUDForView(self.view, animated: false)
            self.setUserDescriptions(self.arrayCheckins[self.curIndexOfCheckin] as PFObject)

//            self.enableLikeButtons(true)
            

            
        }
        
    }
    
    func getLikedUsers()
    {

//        self.enableLikeButtons(false)
        
//        self.arrayLikedMoreUsers.removeAll(keepCapacity: false)
        
        var queryForMatchedUsers = PFQuery(className: "MatchedUsers")
        queryForMatchedUsers.whereKey("userId", equalTo: self.user.objectId)
        self.objLikedUsers = queryForMatchedUsers.getFirstObject()
        if(self.objLikedUsers != nil){
            self.arrayLikedUsers = self.objLikedUsers["matchedUsers"] as Array
        }else{
            self.objLikedUsers = PFObject(className: "MatchedUsers")
            self.objLikedUsers["userId"] = self.user.objectId
            self.arrayLikedUsers.removeAll(keepCapacity: false)
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: false)
        self.removeAllDraggableViews()
        self.fetchMatches()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkIfMatched(userid: String, username: String){

        var matchedUsers:Array<String> = []
        var queryForMatchedUsers = PFQuery(className: "MatchedUsers")
        queryForMatchedUsers.whereKey("userId", equalTo: userid)
        queryForMatchedUsers.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if(object != nil){
                matchedUsers = object["matchedUsers"] as Array
                
                if(contains(matchedUsers, self.user.objectId) == true){
                    let alertView = UIAlertView(title: "Matched!", message: "You were matched with \(username)!", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                    
                    let pushQuery = PFInstallation.query()
                    pushQuery.whereKey("userId", equalTo: userid)
                    
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setMessage("You were matched with \(self.user.username)!")
                    push.sendPushInBackground()
                    
                }
            }
        }
    }

    func cardSwipedRight(viewDraggable:DraggableView)
    {
        

        if(contains(self.arrayLikedUsers, viewDraggable.userId) == false){
//            if(contains(self.arrayLikedMoreUsers, viewDraggable.userId) == false){
            self.arrayLikedUsers.append(viewDraggable.userId)
//                self.arrayLikedMoreUsers.append(viewDraggable.userId)
            self.checkIfMatched(viewDraggable.userId, username: viewDraggable.userName)
//            }
            self.arrayCheckins.removeObject(self.arrayCheckins[self.curIndexOfCheckin])

            var i = self.curIndexOfCheckin
            var tempView = self.view.viewWithTag(100 + i) as DraggableView
            tempView.removeFromSuperview()
            
            while(i<self.arrayCheckins.count){
                i = i + 1
                tempView = self.view.viewWithTag(100 + i) as DraggableView
                tempView.tag = 99 + i

            }
        }
        
        self.view.sendSubviewToBack(viewDraggable)
        NSLog("\(viewDraggable.userId), \(viewDraggable.objId)")
        self.curIndexOfCheckin = self.curIndexOfCheckin - 1
        
        if(self.curIndexOfCheckin >= 0){
            self.setUserDescriptions(self.arrayCheckins[self.curIndexOfCheckin] as PFObject)
        }
        
        self.saveConsideredDatas()
    }
    
    func cardSwipedLeft(viewDraggable:DraggableView)
    {
        
//        if(contains(self.arrayLikedMoreUsers, viewDraggable.userId) == true){
//            self.arrayLikedMoreUsers = self.arrayLikedMoreUsers.filter({$0 != viewDraggable.userId})
//        }
        
        self.view.sendSubviewToBack(viewDraggable)

        self.curIndexOfCheckin = self.curIndexOfCheckin - 1
        if(self.curIndexOfCheckin >= 0){
            self.setUserDescriptions(self.arrayCheckins[self.curIndexOfCheckin] as PFObject)
        }
        
//        self.saveConsideredDatas()
    }
    
    func saveConsideredDatas(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        
        self.objLikedUsers["matchedUsers"] = self.arrayLikedUsers;// + self.arrayLikedMoreUsers
        
        self.objLikedUsers.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
                    if(success == true){
                        NSLog("Success!");
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: false)
        }
        if(self.curIndexOfCheckin < 0){
            self.m_lblCheckInDays.text = "No check in users"
            self.m_lblNameAge.text = ""
            self.m_lblCountOfPhotos.text = "0"
            self.m_btnPrevious.alpha = 1.0
        }
    }
    
    @IBAction func selectUser(sender: UIButton)
    {
        if( self.curIndexOfCheckin >= 0){
            let draggableView = self.arrayDraggableViews.objectAtIndex(self.curIndexOfCheckin) as DraggableView
            if(sender.tag == 1){
                draggableView.leftAction()
            }else{
                draggableView.rightAction()
            }
        }
    }
    
    func removeAllDraggableViews()
    {
        for view in self.view.subviews
        {
            if (view.isKindOfClass(DraggableView))
            {
                view.removeFromSuperview()
            }
        }
        self.arrayDraggableViews = []
        self.curIndexOfCheckin = -1
    }
    func enableLikeButtons(enable:Bool)
    {
        if (enable)
        {
//            self.discardButton.backgroundColor  = UIColor.clearColor()
//            self.likeButton.backgroundColor     = UIColor.clearColor()
            
            self.discardButton.alpha    = 1.0
            self.likeButton.alpha       = 1.0
            self.m_btnInfo.alpha        = 1.0
            self.m_btnPrevious.alpha    = 1.0
//            self.m_btnRefresh.alpha     = 1.0
        }
        else
        {
//            self.discardButton.backgroundColor  = UIColor.blackColor()
//            self.likeButton.backgroundColor     = UIColor.blackColor()
            
            self.discardButton.alpha    = 0.15
            self.likeButton.alpha       = 0.15
            self.m_btnInfo.alpha        = 0.15
//            self.m_btnPrevious.alpha    = 0.15
//            self.m_btnRefresh.alpha     = 0.15
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "InfoPageSegueIdentifier"){
            let destination = segue.destinationViewController as InfoViewController
            destination.strNameAge = self.m_lblNameAge.text
            destination.strCheckedInDays = self.m_lblCheckInDays.text
            destination.object = self.arrayCheckins[self.curIndexOfCheckin] as PFObject
            destination.delegate = self
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if(identifier == "InfoPageSegueIdentifier"){
            if(self.curIndexOfCheckin >= 0){
                return true;
            }else{
                return false;
            }
        }
        return true;
    }

    func setProfileDescription(Name name:String, andPlace place:String, andDistance distance:String)
    {
        var description = name;
        var location:String = place
        if (location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0) {
            location = location + ", " + distance
        }
        if (location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 ) {
            description = name + "\n" + location
        }
        self.m_lblNameAge.text   = description
    }
    
    func calculateAge(dobString:String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat    = "MM/dd/yyyy"
        
        var date    = dateFormatter.dateFromString(dobString)! as NSDate
        var timeInterval    = date.timeIntervalSinceNow
        
        let age = Int(abs(timeInterval / (60 * 60 * 24 * 365))) as Int
        
        return String(age)
    }
    
    func setUserDescriptions(object : PFObject){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let t_userId = object["userId"] as String
        let query = PFUser.query()
        query.whereKey("objectId", equalTo: t_userId)
//        let t_user = query.getFirstObject() as PFUser
//        let dateOfBirth = self.calculateAge(t_user["dobstring"] as String)
//        
//        self.setProfileDescription(Name: t_user.username + ", \(dateOfBirth)", andPlace: "", andDistance:"")
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if(error == nil){
                let dateOfBirth = self.calculateAge(object["dobstring"] as String)
                
                self.setProfileDescription(Name: (object as PFUser).username + ", \(dateOfBirth)", andPlace: "", andDistance:"")
            }
            MBProgressHUD.hideHUDForView(self.view, animated: false)
        }
        let dt = object.updatedAt
        let curDate = NSDate()
        
        let tim :NSTimeInterval = curDate.timeIntervalSinceDate(dt)
        if tim > 86400{
            let t = tim / 86400 + 1
            self.m_lblCheckInDays.text = "Checked in \(Int(t)) days ago"
        }else{
            let t = tim / 3600 + 1
            self.m_lblCheckInDays.text = "Checked in \(Int(t)) hours ago"
        }
        
        let tempArr = object["Photos"] as NSArray
        self.m_lblCountOfPhotos.text = "\(tempArr.count)"
    }
    
    
    @IBAction func btnInfoClicked(sender: AnyObject) {
    }
    
    @IBAction func btnPreviousClicked(sender: AnyObject) {
//        if(self.curIndexOfCheckin == -1){
//            return
//        }else{
//            println("CurrentIndex=\(self.curIndexOfCheckin)")
//        }
        if(self.curIndexOfCheckin < -1){
            self.curIndexOfCheckin = -1
        }
        if(self.curIndexOfCheckin < self.arrayCheckins.count - 1){
            self.curIndexOfCheckin = self.curIndexOfCheckin + 1
            let tempView = self.view.viewWithTag(100 + self.curIndexOfCheckin) as DraggableView
            var k = tempView.tag % 5
            tempView.frame = self.m_imgNoMatched.frame//CGRectMake(13.0 , 74.0 + CGFloat(k) , 295.0, 190.0)
            self.view.bringSubviewToFront(tempView)
            
//            self.enableLikeButtons(true)
            self.setUserDescriptions(self.arrayCheckins[self.curIndexOfCheckin] as PFObject)
        }
    }
    @IBAction func btnRefreshClicked(sender: AnyObject) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated:true)
        self.removeAllDraggableViews()
        self.arrayCheckins = []
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("getLikedUsers"), userInfo: nil, repeats: false)
    }

    func btnLikeClicked() {
        self.selectUser(likeButton)
    }
    
    func btnDiscardClicked() {
        self.selectUser(discardButton)
    }
    
    @IBAction func btnChangeClicked(sender: AnyObject) {
        if(changeButtonTitle == "Change"){
            self.m_txtDiscardChange.hidden = false
            self.m_txtLikeChange.hidden = false
            
            self.m_txtLikeChange.becomeFirstResponder()
            changeButtonTitle = "Done"
            self.m_btnChange.setTitle(changeButtonTitle, forState: UIControlState.Normal)
        }else{
            self.m_txtLikeChange.resignFirstResponder()
            self.m_txtDiscardChange.resignFirstResponder()
            self.setButtonTitles(m_txtLikeChange.text, discardButtonTitle: m_txtDiscardChange.text)
            
        }

    }
    
    func setButtonTitles(likeButtonTitle:String, discardButtonTitle:String){
        self.likeButton.setTitle(likeButtonTitle, forState: UIControlState.Normal)
        self.discardButton.setTitle(discardButtonTitle, forState: UIControlState.Normal)
        self.m_txtLikeChange.hidden = true
        self.m_txtDiscardChange.hidden = true
        changeButtonTitle = "Change"
        self.m_btnChange.setTitle(changeButtonTitle, forState: UIControlState.Normal)
        
        NSUserDefaults.standardUserDefaults().setObject(likeButtonTitle, forKey: "LikeButtonTitle")
        NSUserDefaults.standardUserDefaults().setObject(discardButtonTitle, forKey: "DiscardButtonTitle")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.setButtonTitles(self.m_txtLikeChange.text, discardButtonTitle: self.m_txtDiscardChange.text)
        return true
    }
    
    deinit{
        NSLog("Deinit called!!!")
    }
}
