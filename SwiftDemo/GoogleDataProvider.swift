//
//  GoogleDataProvider.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GoogleDataProvider {
  
  let apiKey = "AIzaSyCzaDYOPPT3Y6cX-Y911oayFkq5sMVUcu8"//"AIzaSyA7DsUQjh17xnwBQFpSXO57a6HZV7MhhYs"
  var photoCache = [String:UIImage]()
  var placesTask = NSURLSessionDataTask()
    
  var session: NSURLSession {

    return NSURLSession.sharedSession()
  }
    
    func fetchAllPlacesNearName(coordinate: CLLocationCoordinate2D, radius: Double, keyword: String, completion: (([GooglePlace]) -> Void)) -> ()
    {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&keyword=\(keyword)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                if let results = json["results"] as? NSArray {
                    for rawPlace:AnyObject in results {
                        let place = GooglePlace(dictionary: rawPlace as NSDictionary, acceptedTypes: [])
                        placesArray.append(place)
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference) { image in
                                place.photo = image
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(placesArray)
            }
        }
        placesTask.resume()
    }

    
    func fetchPlacesNearName(coordinate: CLLocationCoordinate2D, radius: Double, types:[String],keyword:String, completion: (([GooglePlace]) -> Void)) -> ()
    {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&keyword=\(keyword)&rankby=prominence&sensor=false"
        let typesString = types.count > 0 ? join("|", types) : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                if let results = json["results"] as? NSArray {
                    for rawPlace:AnyObject in results {
                        let place = GooglePlace(dictionary: rawPlace as NSDictionary, acceptedTypes: types)
                        placesArray.append(place)
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference) { image in
                                place.photo = image
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(placesArray)
            }
        }
        placesTask.resume()
    }
    
  func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([GooglePlace]) -> Void)) -> ()
  {
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
    let typesString = types.count > 0 ? join("|", types) : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
    if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
      placesTask.cancel()
    }
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      var placesArray = [GooglePlace]()
      if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
        if let results = json["results"] as? NSArray {
          for rawPlace:AnyObject in results {
            let place = GooglePlace(dictionary: rawPlace as NSDictionary, acceptedTypes: types)
            placesArray.append(place)
            if let reference = place.photoReference {
              self.fetchPhotoFromReference(reference) { image in
                place.photo = image
                
              }
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        completion(placesArray)
      }
    }
    placesTask.resume()
  }
  
  
  func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
  {
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?key=\(apiKey)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=walking"
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      var encodedRoute: String?
      if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? [String:AnyObject] {
        if let routes = json["routes"] as AnyObject? as? [AnyObject] {
          if let route = routes.first as? [String : AnyObject] {
            if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
              if let points = polyline["points"] as AnyObject? as? String {
                encodedRoute = points
              }
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        completion(encodedRoute)
      }
    }.resume()
  }
  
  
  func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> ()
  {
    if let photo = photoCache[reference] as UIImage! {
      completion(photo)
    } else {
      let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(apiKey)"
      
//      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        session.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
//                let downloadedPhoto = UIImage(data: data)
//                self.photoCache[reference] = downloadedPhoto
//                dispatch_async(dispatch_get_main_queue()) {
//                  completion(downloadedPhoto)
//                }
//        }).resume()
      session.downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if(url == nil){
            return
        }
        let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url)!)
        self.photoCache[reference] = downloadedPhoto
        dispatch_async(dispatch_get_main_queue()) {
          completion(downloadedPhoto)
        }
      }.resume()
    }
  }
}
