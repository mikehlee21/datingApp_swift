//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Root on 17/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

@objc

class ViewController: UIViewController, FBLoginViewDelegate,PFLogInViewControllerDelegate, UITextFieldDelegate {
    
//    var profilePictureView:FBProfilePictureView = FBProfilePictureView()
    var fbloginView:FBLoginView!// = FBLoginView()
    var facebookLogin:Bool  = false
    @IBOutlet weak var textfieldUserName: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        println("viewDidLoad");
        fbloginView = FBLoginView(readPermissions: ["public_profile", "email", "user_birthday", "user_about_me" ,"user_work_history", "user_education_history", "user_hometown", "user_location"])
        fbloginView.frame   = CGRectMake(60.0, 450.0, 200.0, 44.0)
        fbloginView.delegate = self

        self.view.addSubview(fbloginView)
        
    }
    
    @IBAction func unwindsegue(segue:UIStoryboardSegue){
        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "Accepted")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    override func viewWillAppear(animated: Bool)
    {
        
        let tos = NSUserDefaults.standardUserDefaults().objectForKey("Accepted") as NSString!
        
        if tos == nil {
            self.performSegueWithIdentifier("showTosSegueID", sender: self)
            return
        }
        
        println("viewWillAppear");

        let user = PFUser.currentUser() as PFUser!
        if (user != nil)    //if (self.facebookLogin == true)//if (FBSession.activeSession().isOpen)
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("displayTabs"), userInfo: nil, repeats: false)
            self.facebookLogin  = false
            
//            let installation = PFInstallation.currentInstallation()
//            installation["username"] = user.username
//            installation["userId"] = user.objectId
//            installation.channels = ["Global", NSString(string: "A\(user.objectId)")];
//            installation.saveInBackground()
        }
        else {
            FBSession.activeSession().closeAndClearTokenInformation()
            NSUserDefaults.standardUserDefaults().removeObjectForKey("cityCheckIn")
            NSUserDefaults.standardUserDefaults().synchronize()
            
//            let installation = PFInstallation.currentInstallation()
//            installation.channels = ["Global"];
//            installation.saveInBackground()
        }
        
    }
    
    @IBAction func signIn(sender: UIButton)
    {
        
        println("signIn");
//        self.displayTabs()

        
        self.signInButton.enabled = false
        self.signUpButton.enabled = false
        
        var message = ""
        
        if (self.textfieldPassword.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "Password should not be empty"
        }
        
        if (self.textfieldUserName.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "User Name should not be empty"
        }
        
        if (message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0)
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
            
            self.signInButton.enabled = true
            self.signUpButton.enabled = true
        }
        
        else
        {
            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            PFUser.logInWithUsernameInBackground(self.textfieldUserName.text , password:self.textfieldPassword.text)
                {
                    (user: PFUser!, error: NSError!) -> Void in
                    if (user != nil)
                    {
                        let installation = PFInstallation.currentInstallation()
                        installation["username"] = user.username
                        installation["userId"] = user.objectId
                        installation.saveInBackground()
                        
                        self.displayTabs()
                    }
                    else
                    {
                        if let errorString = error.userInfo?["error"] as? NSString
                        {
                            var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                        
                            alert.show()
                        }
                        
                        
                    }
                    
                    self.signInButton.enabled = true
                    self.signUpButton.enabled = true

                    MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
        }
        
    }

    override func viewWillLayoutSubviews()
    {
        super.viewWillAppear(false)
        //println("viewWillLayoutSubviews")
    }

    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!)
    {
        //self.profilePictureView.profileID = user.id
        
        println("loginViewFetchedUserInfo")
        var query = PFUser.query()
        
        query.whereKey("fbID", equalTo: user.id)
        //
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
            else{
                
                if (objects.count == 0)
                {
/*                    fbloginView.readPermissions = ["email"];
                    var me:FBRequest = FBRequest.requestForMe()
                    me.startWithCompletionHandler({(NSArray my, NSError error) in*/
                    
                    
                    
                    println(user)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let imageUploaderView = storyboard.instantiateViewControllerWithIdentifier("ImageSelectorViewController") as ImageSelectorViewController
                    var email:String? = user.objectForKey("email") as String?
                    var birthday:String? = user.birthday
                    if (email==nil) {
                        email = user.name + "@user.com"
                    }
                    if (birthday==nil) {
                        birthday = "10/10/1987"
                    }

                    imageUploaderView.setUserName(user.name, password: user.id, Email: email!, andDateOfBirth: birthday!)
                    imageUploaderView.facebookLogin = true
                    self.facebookLogin  = true
                    imageUploaderView.user  = user
                    
                    MBProgressHUD.hideHUDForView(self.view, animated:false)
                    imageUploaderView.loginScreen = self;
                    self.navigationController!.pushViewController(imageUploaderView, animated: true)
                }
                else
                {
                    PFUser.logInWithUsernameInBackground(user.name , password:user.id)
                        {
                            (user: PFUser!, error: NSError!) -> Void in
                            if (user != nil)
                            {
                                /*
                                var alert:UIAlertView = UIAlertView(title: "Message", message: "Hi " + user.username + ". You logged in", delegate: nil, cancelButtonTitle: "Ok")
                                
                                alert.show()
                                */
                                
                                MBProgressHUD.hideHUDForView(self.view, animated:false)
                                self.displayTabs()
                            }
                            else
                            {
                                MBProgressHUD.hideHUDForView(self.view, animated:false)
                                if let errorString = error.userInfo?["error"] as? NSString
                                {
                                    var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                                    
                                    alert.show()
                                }
                            }
                            
                            self.signInButton.enabled = true
                            self.signUpButton.enabled = true
                    }
                }
            }
        })
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!)
    {
        println("loginViewShowingLoggedInUser")
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!)
    {
        println("loginViewShowingLoggedOutUser")
//        self.profilePictureView.profileID = nil
    }
    
    
    func displayTabs()
    {
        println("displayTabs")
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let containerViewController = storyboard.instantiateViewControllerWithIdentifier("MainContainViewController") as UIViewController
        
        delegate.window?.rootViewController = containerViewController
        
        
        MBProgressHUD.hideHUDForView(self.view, animated:false)
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

