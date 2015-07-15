//
//  CheckInViewController.swift
//  TestApp2
//
//  Created by macos on 11/30/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI
var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant", "park", "shop", "hotel", "city"]
let apiKey = "AIzaSyCzaDYOPPT3Y6cX-Y911oayFkq5sMVUcu8"
class CheckInViewController: UITableViewController, UISearchBarDelegate {

//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//        
//    }
    @IBOutlet weak var searchPlaceBar: UISearchBar!
    var arrLocations : Array<PFObject> = []
    var arrSearchResults : Array<PFObject> = []
    var query : PFQuery!
    var locService : Bool!
    var localSearch : MKLocalSearch!
    var arrLocalSearchResults : Array<MKMapItem> = []
    var curPlace : GooglePlace!

//    Using Google
    let dataProvider = GoogleDataProvider()
    var nearbyPlaces : Array<GooglePlace> = []
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        var cellData : PFObject!
        if(segue.identifier == "CheckInIdentifier"){
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
            
            var dest : CheckInCompleteViewController = segue.destinationViewController as CheckInCompleteViewController
            dest.txtDescription = "-at " + nearbyPlaces[indexPath.row].name + "\n" + nearbyPlaces[indexPath.row].address
            dest.imgPhoto = nearbyPlaces[indexPath.row].photo
            dest.coord = nearbyPlaces[indexPath.row].coordinate
            dest.idxPath = indexPath
        }
    }
    
    func locationUpdated(){
        var dicPlace : NSMutableDictionary!
        dicPlace = NSMutableDictionary()
        dicPlace["name"] = GlobalVariableSharedInstance.locationName?
        dicPlace["vicinity"] = "City" // GlobalVariableSharedInstance.locationAddress?
        let temp1 = NSMutableDictionary()
        temp1.setObject(GlobalVariableSharedInstance.currentLocation().coordinate.latitude as CLLocationDegrees, forKey: "lat")
        temp1.setObject(GlobalVariableSharedInstance.currentLocation().coordinate.longitude as CLLocationDegrees, forKey: "lng")
        
        dicPlace["geometry"] = NSDictionary(object: temp1, forKey: "location")
        dicPlace["types"] = ["city"]
        curPlace = GooglePlace(dictionary: dicPlace, acceptedTypes: searchedTypes)
        
        if(self.nearbyPlaces.count > 0){
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationUpdated"), name: "LocationUpdated", object: nil)
        
        locService = false;
        query = nil;
        self.view.addGestureRecognizer( self.revealViewController().panGestureRecognizer())
        
        self.title = "Check In"
        
        let menuImageView = UIImageView(image: UIImage(named: "Menu30.png"))
        let leftBarButton = UIBarButtonItem(image: menuImageView.image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("menuClicked"))
        self.navigationItem.leftBarButtonItem = leftBarButton

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.locationUpdated()
    }
    
    func menuClicked(){
        NSLog("Menu Button Clicked!")
        
        let user = PFUser.currentUser()
        let lastCheckin = NSUserDefaults.standardUserDefaults().objectForKey("cityCheckIn") as String!
        
        if lastCheckin != nil{
            searchPlaceBar.resignFirstResponder()
            self.revealViewController().revealToggleAnimated(true)
        }else{
            let alertView = UIAlertView(title: "Error", message: "You should check in at least one time!", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(nearbyPlaces.count > 0){//searchPlaceBar.text != ""){
            self.tableView.reloadData()
        }else{
            self.searchNearbyPlaces()
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPlaces.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat

        return 64
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        NSLog("%d", indexPath.row)
        var cell : UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("NormalCellIdentifier") as UITableViewCell
        cell.imageView?.image = UIImage(named: "locImage.png")
        cell.textLabel?.text = nearbyPlaces[indexPath.row].name
        cell.detailTextLabel?.text = nearbyPlaces[indexPath.row].address
        if(nearbyPlaces[indexPath.row].photo == nil){
            if(nearbyPlaces[indexPath.row].photoReference != nil){
                let strName = nearbyPlaces[indexPath.row].photoReference as NSString!
              let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(strName)&key=\(apiKey)"
                NSLog("URL: \(nearbyPlaces[indexPath.row].photoReference)")
                cell.imageView?.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!)
            }
        }else{
            cell.imageView?.image = nearbyPlaces[indexPath.row].photo
        }

        return cell
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        NSLog("%d", indexPath.row)
//    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        self.searchNearbyPlaces()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        self.searchNearbyPlaces()

    }
    
    func searchNearbyPlaces(){
//        let tempCoord = CLLocationCoordinate2D(latitude: 32.78343974129825, longitude: -117.2532294487971)
        if(searchPlaceBar.text == ""){
            dataProvider.fetchAllPlacesNearName(GlobalVariableSharedInstance.currentLocation().coordinate/*tempCoord*/, radius: 322,keyword:"restaurant", completion: { (places: [GooglePlace]) -> Void in
                self.nearbyPlaces = places
                self.nearbyPlaces.insert(self.curPlace, atIndex: 0)
                self.tableView.reloadData()
            })

        }else{
            dataProvider.fetchAllPlacesNearName(GlobalVariableSharedInstance.currentLocation().coordinate/*tempCoord*/, radius: 322,keyword:searchPlaceBar.text, completion: { (places: [GooglePlace]) -> Void in
                self.nearbyPlaces = places
                self.nearbyPlaces.insert(self.curPlace, atIndex: 0)
                self.tableView.reloadData()
            })
            
        }
    }
    
    func searchWithMap(searchText: String){
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchText
        
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) -> Void in
            if(error==nil){
                NSLog("\n\n%@\n", searchText)
                self.arrLocalSearchResults = response.mapItems as Array<MKMapItem>
                self.tableView.reloadData()
            }
        }
    }
    
    func searchWithPlaceName(placeName: String){
        
        if(query != nil){
            query.cancel()
            query = nil;
        }

        query = PFQuery(className: "Places")
        query.whereKey("PlaceName", containsString: placeName)
        query.limit = 13;
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if( error == nil){
                NSLog("Successfully retrieved \(objects.count) results")
                self.arrSearchResults = objects as Array
                for object in objects{
                    NSLog("PlaceName:%@", object["PlaceName"] as String)
                }
            }else{
                self.arrSearchResults = []
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            self.tableView.reloadData()

        }
    }
    
    func searchWithPlaceCoordinates(){

        if(query != nil){
            query.cancel()
            query = nil;
        }
        
        
//        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
//            if(error == nil){
        if(locService == true){
            let geoPoint : PFGeoPoint = PFGeoPoint(location: GlobalVariableSharedInstance.currentLocation())
         
            NSLog("\(geoPoint.latitude) \(geoPoint.longitude)");
            
                self.query = PFQuery(className: "Places")
                self.query.whereKey("PlaceCoord", nearGeoPoint: geoPoint, withinMiles: 10)
                self.query.limit = 13
                
                self.query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    
                    if( error == nil){
                        self.arrLocations = objects as Array
                    }else{
                        self.arrLocations = []
                    }
                    NSLog("SearchWithCoordinates")
                    self.tableView.reloadData()
                })
            }else{
                self.arrLocations = [];
                self.tableView.reloadData()
            }
    }
//        }
//    }
    
}
