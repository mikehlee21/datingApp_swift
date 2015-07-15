//
//  LocationManager.swift
//  ImageUploader
//
//  Created by Root on 03/08/14.
//
//

import Foundation
import UIKit
import CoreLocation
import AddressBookUI

class LocationManager: NSObject,  CLLocationManagerDelegate
{
    var coreLocationManager = CLLocationManager()
    var locationAddress : NSString!
    var locationName: NSString!
    
    class var SharedLocationManager:LocationManager
    {
        return GlobalVariableSharedInstance
    }
    func locationServiceAuthorized() -> Bool{
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied){
            return false;
        }
        return true;
    }
    func initLocationManager()
    {
        if(self.locationName == nil){
            self.locationName = "Searching..."
        }
        if(self.locationAddress == nil){
            self.locationAddress = "........."
        }
        if (CLLocationManager.locationServicesEnabled())
        {
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied){
                let alert: UIAlertView = UIAlertView(title: "App Permission Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            coreLocationManager.delegate = self
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            if(self.coreLocationManager.respondsToSelector("requestWhenInUseAuthorization")){
                self.coreLocationManager.requestWhenInUseAuthorization()
                
            }
            coreLocationManager.startUpdatingLocation()
            coreLocationManager.startMonitoringSignificantLocationChanges()
        }
        else
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: "Location Services not Enabled. Please enable Location Services", delegate: nil, cancelButtonTitle: "ok")
            alert.show()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        if (locations.count > 0)
        {
            var newLocation:CLLocation = locations[0] as CLLocation
            NSLog("%le: %le", newLocation.coordinate.longitude, newLocation.coordinate.latitude)
            
            let geoCoder : CLGeocoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation( newLocation, completionHandler: { (objects :[AnyObject]!, error :NSError!) -> Void in
                if(error ==  nil){
                    var placemark : CLPlacemark = objects.last as CLPlacemark

    //                NSLog("\(placemark)")
    //                NSLog("AddressBook:\n%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, false))
                    
    //                self.locationAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                    self.locationName = placemark.locality
                    self.locationAddress = placemark.name
    //                self.locationAddress = self.locationAddress.stringByReplacingOccurrencesOfString("\n", withString: " ")
                    
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "LocationUpdated", object: nil))
                }
                
            })
            
//            coreLocationManager.stopUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.Authorized)
        {
            println("Autherized")
        }
        else if(status == CLAuthorizationStatus.Denied)
        {
            println("Anautherized")
            coreLocationManager.stopUpdatingLocation()
            coreLocationManager.stopMonitoringSignificantLocationChanges()
            coreLocationManager.delegate = nil
        }
    }
    
    func currentLocation() -> CLLocation {
        var location:CLLocation? = coreLocationManager.location
        if (location==nil) {
            location = CLLocation(latitude: 51.368123, longitude: -0.021973)
        }
/*        if (("iPhone Simulator" == UIDevice.currentDevice().model) || ("iPad Simulator" == UIDevice.currentDevice().model))
        {//51.368123,-0.021973, 41.8059,  123.4323
            location = CLLocation(latitude: 51.368123, longitude: -0.021973)
        }
*/
        return location!
    }
    
    func findDistance(location:PFGeoPoint!) -> NSNumber
    {
        var distance:CLLocationDistance = -1
        if ((location) != nil)
        {
            var locationFromGeoPoint:CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let current_location:CLLocation? = GlobalVariableSharedInstance.currentLocation()
            distance = abs(locationFromGeoPoint.distanceFromLocation(current_location))
        }
        
        
        return NSNumber(double: distance)
    }
}

let GlobalVariableSharedInstance = LocationManager()