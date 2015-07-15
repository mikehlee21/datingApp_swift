//
//  AddPlaceViewController1.swift
//  TestApp2
//
//  Created by macos on 12/1/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit
import MapKit

class AddPlaceViewController1: UIViewController, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var m_backView1: UIView!
    @IBOutlet weak var m_txtPlaceName: UITextField!
    @IBOutlet weak var m_imgPlace: UIImageView!
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_mapView: MKMapView!
    var oriCoordForMap : CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Place"
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("btnAddClicked:"))
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.m_backView1.layer.cornerRadius = 5
        self.m_backView1.layer.masksToBounds = true
        
        let gestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tappedImage:"))
        self.m_imgPlace.addGestureRecognizer(gestureRecognizer)
        self.m_imgPlace.userInteractionEnabled = true
        
    }
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        oriCoordForMap = CGPointMake(self.view.frame.size.width/2, 50)
//        self.m_mapView.center = oriCoordForMap
//        self.m_mapView.setCenterCoordinate(self.m_mapView.userLocation.location.coordinate, animated: false)
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.m_mapView.setCenterCoordinate(GlobalVariableSharedInstance.currentLocation().coordinate, animated: true)
    }
    
    func btnAddClicked(button : UIBarButtonItem){
        
        if(m_imgPlace.image == nil){
            return;
        }
        if(m_txtPlaceName.text == ""){
            return;
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        
        let geoPoint: PFGeoPoint = PFGeoPoint(location: GlobalVariableSharedInstance.currentLocation())
        let obj : PFObject = PFObject(className: "Places")
        obj.setObject(m_txtPlaceName.text, forKey: "PlaceName")
        obj.setObject(geoPoint, forKey: "PlaceCoord")
        obj.setObject(GlobalVariableSharedInstance.locationAddress, forKey: "LocAddress")
        
        let imgData : NSData = UIImageJPEGRepresentation(m_imgPlace.image, 0.7)
        let file : PFFile = PFFile(data: imgData)
        file.saveInBackgroundWithBlock { (success :Bool, error: NSError!) -> Void in
            if(error == nil){
                obj.setObject(file, forKey: "PlaceImage")
                obj.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                    NSLog("Successfully saved!")
                    
                    MBProgressHUD.showHUDAddedTo(self.view, animated:false)
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }else{
                MBProgressHUD.showHUDAddedTo(self.view, animated:false)
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationItem.leftBarButtonItem?.enabled = true
            }
        }
    }
    
    func tappedImage(gesture : UIGestureRecognizer){
        let actionSheet : UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Suggest Photo", "Take Photo")
        actionSheet.showInView(self.view)
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
        self.m_imgPlace.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
