//
//  SignUpController.swift
//  SwiftDemo
//
//  Created by Root on 19/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, UITextFieldDelegate
{

    var pickerContainer = UIView()
    var picker = UIDatePicker()
    
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var emailAddressTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var dateOfBirthButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordTextfield.text = ""
        self.emailAddressTextfield.text = ""
        self.userNameTextfield.text = ""
        self.dateOfBirthButton.setTitle("", forState: UIControlState.Normal)
        
        configurePicker()
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

    @IBAction func selectDateOfBirth(sender: AnyObject)
    {
        
        self.userNameTextfield.resignFirstResponder()
        self.emailAddressTextfield.resignFirstResponder()
        self.passwordTextfield.resignFirstResponder()
                
        UIView.animateWithDuration(0.4, animations: {
            
            var frame:CGRect = self.pickerContainer.frame
            frame.origin.y = self.view.frame.size.height - 300.0 + 84
            self.pickerContainer.frame = frame
            
        })
    }
    
    func dismissPicker ()
    {
        UIView.animateWithDuration(0.4, animations: {
            
            self.pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            self.dateOfBirthButton.setTitle(dateFormatter.stringFromDate(self.picker.date), forState: UIControlState.Normal)
        })
    }
    @IBAction func nextScreen(sender: UIButton)
    {
        
        var message = ""
        
        if (self.dateOfBirthButton.titleForState(UIControlState.Normal)!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "Please provide date of birth"
        }
        if (self.passwordTextfield.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "Pasword should not be empty"
        }
        if (self.emailAddressTextfield.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "Email address should not be empty"
        }
        if (self.userNameTextfield.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "User name should not be empty"
        }
        
        if (message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0)
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let imageUploaderView = storyboard.instantiateViewControllerWithIdentifier("ImageSelectorViewController") as ImageSelectorViewController
            imageUploaderView.setUserName(self.userNameTextfield.text, password: self.passwordTextfield.text, Email: self.emailAddressTextfield.text, andDateOfBirth: self.dateOfBirthButton.titleForState(UIControlState.Normal)!)
            self.navigationController!.pushViewController(imageUploaderView, animated: true)
        }

        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageUploaderView = storyboard.instantiateViewControllerWithIdentifier("ImageSelectorViewController") as ImageSelectorViewController
        imageUploaderView.setUserName(self.userNameTextfield.text, password: self.passwordTextfield.text, Email: self.emailAddressTextfield.text, andDateOfBirth: self.dateOfBirthButton.titleForState(UIControlState.Normal))
        self.navigationController.pushViewController(imageUploaderView, animated: true)
        */
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        UIView.animateWithDuration(0.4, animations: {
            
            self.pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
            
        })
    }
}
