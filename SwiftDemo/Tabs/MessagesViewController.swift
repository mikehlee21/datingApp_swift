//
//  MessagesViewController.swift
//  SwiftDemo
//
//  Created by Root on 24/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {

    var selectedUser:PFUser = PFUser()
    var profileImage:UIImage = UIImage()

    @IBOutlet var profilePicture : UIImageView?
    @IBOutlet var messages : UILabel?
    @IBOutlet weak var messageTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profilePicture!.image   = profileImage
        
        let dateOfBirth:String = self.calculateAge(selectedUser["dobstring"] as String)
        let gender:String   = selectedUser["gender"] as String
        let interest:String  = selectedUser["interestedin"] as String
        let emailID:String  = selectedUser.email as String
        self.messages!.text  = NSString(format: "%@, %@, %@ \nInterested In: %@\nEmail ID: %@", selectedUser.username, dateOfBirth, gender, interest, emailID)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateAge(dobString:String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat    = "MM/dd/yyyy"
        
        var date    = dateFormatter.dateFromString(dobString) as NSDate!
        if (date==nil) {
            return "10";
        }
        var timeInterval    = date.timeIntervalSinceNow
        
        let age = Int(abs(timeInterval / (60 * 60 * 24 * 365))) as Int
        println(age)
        return String(age)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
