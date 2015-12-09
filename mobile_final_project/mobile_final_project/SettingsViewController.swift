//
//  SettingsViewController.swift
//  mobile_final_project
//
//  Created by Nathan Vahrenberg on 11/20/15.
//  Copyright © 2015 Christopher Ray. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase


class SettingsViewController: UITableViewController, CLLocationManagerDelegate
{
    //declaring variables
    var userRef: Firebase!  //users in firebase
    var locationManager: CLLocationManager! //location manager
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var location:CLLocationCoordinate2D!
    var pairondistance = 1.0    //whether or not user will pair on distance
    var paironinterest = 1.0    //whether or not user will pair on interests
    var userID = ""
    var codeName = ""   //user codename
    var buddyID = ""
    var buddy = ""  //buddy codename
    var temp_buddy = ""
    var paired = false  //whether or not user is paired
    var initialPair = false //whether or not user has gone through 1 pairing
    var range = 0   //
    var totalanon = 0

    @IBOutlet weak var toggle1: UISwitch!
    @IBOutlet weak var toggle2: UISwitch!
    @IBOutlet weak var rangeslider: UISlider!
    @IBOutlet weak var rangetext: UILabel!
    @IBOutlet weak var interest1: UITextField!
    @IBOutlet weak var interest2: UITextField!
    @IBOutlet weak var confirmbutton: UIBarButtonItem!
    @IBOutlet weak var interest3: UITextField!
    @IBOutlet weak var codename: UITextField!
    @IBOutlet weak var staticRangeText: UILabel!
   
    
    @IBAction func InterestSwitch(sender: AnyObject)
    {
        if self.paironinterest == 1
        {
            self.paironinterest = 0
        }
        else
        {
            self.paironinterest = 1
        }
    }
    
    @IBAction func RangeSwitch(sender: AnyObject)
    {
        if staticRangeText.textColor == UIColor.lightGrayColor()
        {
            staticRangeText.textColor = UIColor.blackColor()
            rangetext.textColor = UIColor.blackColor()
            self.pairondistance = 1
        }
        else
        {
            staticRangeText.textColor = UIColor.lightGrayColor()
            rangetext.textColor = UIColor.lightGrayColor()
            self.pairondistance = 0
        }
        
    }
    
    func calcDistance(lat1: CLLocationDegrees, long1: CLLocationDegrees, lat2: CLLocationDegrees, long2: CLLocationDegrees) -> Double
    {
        let R = 6371000.0
        let r_lat1 = lat1 * M_PI / 180.0
        let r_lat2 = lat2 * M_PI / 180.0
        let delta_lat = (lat2 - lat1) * M_PI / 180.0
        let delta_long = (long2 - long1) * M_PI / 180.0
        
        let A = sin(delta_lat / 2) * sin(delta_lat / 2) + cos(r_lat1) * cos(r_lat2) * sin(delta_long / 2) * sin(delta_long / 2)
        let C = 2 * atan2(sqrt(A), sqrt(1 - A))
        let D = R * C
        
        return D
    }
    
    func insertNewUser(){
        if(initialPair)
        {
            let uref = userRef.childByAppendingPath(userID)
            
            uref.removeValue()
            
            paired = false
            buddyID = ""
            temp_buddy = ""
            buddy = ""
        }
        
        // Generate unique userID
        userID = String(Int(NSDate().timeIntervalSinceReferenceDate) + rand())
        
        print("uid:  " + userID)
        
        var i1 = ""
        if (!interest1.text!.isEmpty){
            i1 = interest1.text!.lowercaseString
        }
        
        var i2 = ""
        if (!interest2.text!.isEmpty){
            i2 = interest2.text!.lowercaseString
        }
        
        var i3 = ""
        if (!interest3.text!.isEmpty){
            i3 = interest3.text!.lowercaseString
        }
        
        var n = "Anonymous"
        if (!codename.text!.isEmpty){
            n = codename.text!
            self.codeName = n
        }
        
        // Adds new user
        userRef.childByAppendingPath(userID).setValue([
            "codename":  n,
            "interest1": i1,
            "interest2": i2,
            "interest3": i3,
            "buddy": "",
            "paired": 0,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "totalanon": self.totalanon])
       
            userRef.queryOrderedByKey().observeEventType(.Value, withBlock:
            { snapshot in
                if(!(snapshot.value is NSNull))
                {
                    let enumerator = snapshot.children
                    while let rest = enumerator.nextObject() as? FDataSnapshot
                    {
                        if (self.pairondistance == 1) && (self.paironinterest == 0)
                        {
                            print ("Pair only on distance")
                            let pair = rest.value["paired"] as? Int
                            let a = rest.value["latitude"] as? Double
                            let b = rest.value["longitude"] as? Double
                            let c = rest.value["codename"] as? String
                            let d = self.calcDistance(self.latitude, long1: self.longitude, lat2: a!, long2: b!)
                            print("\(d)")
                            if((pair == 0) && (d <= Double(self.range)) && (rest.key != self.userID) && (self.buddyID == ""))
                            {
                                self.buddyID = rest.key
                                self.buddy = c!
                                self.pairUsers()
                                break
                            }
                        }
                        else if(self.pairondistance == 0) && (self.paironinterest == 1)
                        {
                            print ("Pair only on interest")
                            let pair = rest.value["paired"] as? Int
                            let c = rest.value["codename"] as? String
                            let b1 = rest.value["interest1"] as? String
                            let b2 = rest.value["interest2"] as? String
                            let b3 = rest.value["interest3"] as? String
                            if((pair == 0) && (rest.key != self.userID) && (self.buddyID == ""))
                            {
                                if (self.matchInterest(i1, I2: i2, I3: i3, B1: b1!, B2: b2!, B3: b3!)==1) {
                                    self.buddyID = rest.key
                                    self.buddy = c!
                                    self.pairUsers()
                                    break
                                }
                            }
                        }
                        else if(self.pairondistance == 1) && (self.paironinterest == 1)
                        {
                            print ("Pair on both distance and interest")
                            let pair = rest.value["paired"] as? Int
                            let a = rest.value["latitude"] as? Double
                            let b = rest.value["longitude"] as? Double
                            let c = rest.value["codename"] as? String
                            let b1 = rest.value["interest1"] as? String
                            let b2 = rest.value["interest2"] as? String
                            let b3 = rest.value["interest3"] as? String
                            // let d = sqrt(pow((self.latitude - a!), 2) + pow((self.longitude -   b!), 2))
                            let d = self.calcDistance(self.latitude, long1: self.longitude, lat2: a!, long2: b!)
                            if((pair == 0) && (d <= Double(self.range)) && (rest.key != self.userID) && (self.buddyID == ""))
                            {
                                if (self.matchInterest(i1, I2: i2, I3: i3, B1: b1!, B2: b2!,    B3: b3!)==1) {
                                    self.buddyID = rest.key
                                    self.buddy = c!
                                    self.pairUsers()
                                    break
                                }
                            }
                        }
                        else
                        {
                            print ("Pair by total anon")
                            let pair = rest.value["paired"] as? Int
                            let c = rest.value["codename"] as? String
                            let t = rest.value["totalanon"] as? Int
                            if((pair == 0) && (rest.key != self.userID) && (self.buddyID == "") && (t == 1))
                            {
                                self.buddyID = rest.key
                                self.buddy = c!
                                self.pairUsers()
                                break
                            }
                        }
                    }
    
                }
            })
        
        if self.buddyID == "" && self.paired == false
        {
            print ("No one to pair with currently")
        }
        else
        {
           // self.pairUsers()
        }
    }
    
    func matchInterest(I1:String, I2:String, I3:String, B1:String, B2:String, B3:String) -> Int{
        print ("In Match Interest Function")
        
        if (I1 == "" && I2 == "" && I3 == ""){
            return 1
        }
        
        var I1 = I1
        var I2 = I2
        var I3 = I3

        if (I1 == ""){ I1 = "null"}
        if (I2 == "") { I2 = "null"}
        if (I3 == "") { I3 = "null"}
        
        if (B1 != ""){
            if B1 == I1 || B1 == I2 || B1 == I3 {
                return 1
            }
        }
        
        if (B2 != ""){
            if B2 == I1 || B2 == I2 || B2 == I3 {
                return 1
            }
        }
        
        if (B3 != ""){
            if B3 == I1 || B3 == I2 || B3 == I3 {
                return 1
            }
        }
    
        return 0
    }
    
    func pairUsers()
    {
        self.paired = true
        self.initialPair = true
        let buddyRef = self.userRef.childByAppendingPath(buddyID)
        let uRef = self.userRef.childByAppendingPath(userID)
        
        let pairUpdate = ["paired":  1]
        buddyRef.updateChildValues(pairUpdate)
        uRef.updateChildValues(pairUpdate)
        
        let buddyUpdate = ["buddy":  userID]
        let userUpdate = ["buddy":  buddyID]
        buddyRef.updateChildValues(buddyUpdate)
        uRef.updateChildValues(userUpdate)
        
        //buddyID = ""
        performSegueWithIdentifier("toFireChat", sender: self)
    }
    
 
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "toFireChat") {
            let svc = segue!.destinationViewController as! MessagesViewController;
            
            
            
            // Pass userID and buddyID to next view
            svc.userID = userID
            svc.buddyID = buddyID
            svc.buddy = buddy
            svc.codeName = codeName
        }
    }
    
    @IBAction func ButtonPressed(sender: UIBarButtonItem) {
        
        if paironinterest == 0 && pairondistance == 0 {
            totalanon = 1
        }
        
        self.title = "Waiting..."
        
        insertNewUser()
        
        let waitingAnimation = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        waitingAnimation.hidesWhenStopped = true
        waitingAnimation.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: waitingAnimation)
        
        
            
        //performSegueWithIdentifier("toFireChat", sender: self)
    }

    @IBAction func rangevaluechanged(sender: UISlider) {
        let currentvalue = Int(sender.value)
        rangetext.text = String(currentvalue)
        range = currentvalue
    }
    
    override func viewDidAppear(animated: Bool) {
        self.title = "Settings"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "ButtonPressed:")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Settings"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "ButtonPressed:")
        
        userRef = Firebase(url: "https://incandescent-torch-8912.firebaseio.com/users")
        
        codename.text = "Anonymous"
        rangetext.text = "1000"
        interest1.text = ""
        interest2.text = ""
        interest3.text = ""
        
        
        if (CLLocationManager.locationServicesEnabled()) //checking if location services are activated
        {
            self.locationManager = CLLocationManager()  //initializing location manager
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.latitude = self.locationManager.location!.coordinate.latitude
        self.longitude = self.locationManager.location!.coordinate.longitude
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}