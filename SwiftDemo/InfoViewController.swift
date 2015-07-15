//
//  InfoViewController.swift
//  Fate
//
//  Created by macos on 12/3/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit
import MessageUI
@objc protocol InfoViewControllerDelegate{
    func btnLikeClicked()
    func btnDiscardClicked()
}

class InfoViewController: UIViewController, UIScrollViewDelegate , UIActionSheetDelegate, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var m_pageControl: UIPageControl!
    
    @IBOutlet weak var m_contentScrollView: UIScrollView!
    @IBOutlet weak var m_photoScrollView: UIScrollView!
    @IBOutlet weak var m_lblNameAge: UILabel!
    var strNameAge : NSString!
    @IBOutlet weak var m_lblCheckedInDays: UILabel!
    var strCheckedInDays : NSString!
    @IBOutlet weak var m_btnDiscard: UIButton!
    @IBOutlet weak var m_btnLike: UIButton!
    @IBOutlet weak var m_lblFrom: UILabel!
    var strFrom : NSString!
    @IBOutlet weak var m_lblCurrentCity: UILabel!
    var strCurrentCity : NSString!
    @IBOutlet weak var m_lblAbout: UILabel!
    var strAbout : NSString!
    @IBOutlet weak var m_lblWork: UILabel!
    var strWork : NSString!
    @IBOutlet weak var m_lblEducation: UILabel!
    var strEducation : NSString!
    
    var object : PFObject!
    var delegate : InfoViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        
        var likeButtonTitle = NSUserDefaults.standardUserDefaults().objectForKey("LikeButtonTitle") as String!
        var discardButtonTitle = NSUserDefaults.standardUserDefaults().objectForKey("DiscardButtonTitle") as String!
        
        self.m_btnLike
            .setTitle(likeButtonTitle, forState: UIControlState.Normal)
        self.m_btnDiscard.setTitle(discardButtonTitle, forState: UIControlState.Normal)
        
        let titleImageView = UIImageView(image: UIImage(named: "30.png"))
        self.navigationItem.titleView = titleImageView;
        let rightBarButton = UIBarButtonItem(title: "Report", style: UIBarButtonItemStyle.Bordered,  target: self, action: Selector("more:")) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.m_btnDiscard.layer.cornerRadius = 5
        self.m_btnLike.layer.cornerRadius = 5
        
        self.m_btnLike.layer.shadowOpacity = 0.5
        self.m_btnLike.layer.shadowRadius = 1.0
        self.m_btnLike.layer.shadowOffset = CGSizeMake(-1, 2)
        
        self.m_btnDiscard.layer.shadowOpacity = 0.5
        self.m_btnDiscard.layer.shadowRadius = 1.0
        self.m_btnDiscard.layer.shadowOffset = CGSizeMake(-1, 2)
        
//        self.m_contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 750)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.m_contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 750, 0)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.m_lblNameAge.text = strNameAge
        self.m_lblCheckedInDays.text = strCheckedInDays
        
//        let arrayFiles = object["Photos"] as NSMutableArray
        var arrayFiles = NSMutableArray()
        let userQuery = PFQuery(className: "UserPhoto")
        userQuery.whereKey("userId", equalTo: object["userId"])
        let userObj = userQuery.getFirstObject()
        
        arrayFiles.addObject(userObj["Photos"].objectAtIndex(0))
        m_pageControl.currentPage = 0
        
        for fl in object["Photos"] as NSArray {
            arrayFiles.addObject(fl)
        }

        m_pageControl.numberOfPages = arrayFiles.count
        
        var i : NSInteger
        i = 0
        for obj in arrayFiles{
            let imageData:NSData    = obj.getData()
            let image               = UIImage(data: imageData)
            
            var frame : CGRect
            frame = self.m_photoScrollView.frame
            frame.origin.x = frame.size.width * CGFloat(i)
            frame.origin.y = 0
            
            let imgView = UIImageView(image: image)
            imgView.frame = frame
            imgView.contentMode = UIViewContentMode.ScaleAspectFit
            self.m_photoScrollView.addSubview(imgView)
            i = i + 1
        }
        self.m_photoScrollView.contentSize = CGSizeMake( self.m_photoScrollView.frame.size.width * CGFloat(i), self.m_photoScrollView.frame.size.height)
        
        let userId = object["userId"] as String
        let query = PFUser.query()
        query.whereKey("objectId", equalTo: userId)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if(error == nil){
                self.m_lblFrom.text = object["COUNTRY"] as? String
                self.m_lblCurrentCity.text = object["CITY"] as? String
                self.m_lblAbout.text = object["ABOUT"] as? String
                self.m_lblWork.text = object["WORK"] as? String
                self.m_lblEducation.text = object["EDUCATION"] as? String
            }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: false)
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.m_photoScrollView.frame.size.width
        let page = floor((self.m_photoScrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1
        self.m_pageControl.currentPage = NSInteger(page)
    }
    
    @IBAction func btnLikeClicked(sender: AnyObject) {
        self.delegate.btnLikeClicked()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnDiscardClicked(sender: AnyObject) {
        self.delegate.btnDiscardClicked()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
