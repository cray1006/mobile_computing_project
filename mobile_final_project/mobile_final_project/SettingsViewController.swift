//
//  SettingsViewController.swift
//  mobile_final_project
//
//  Created by Nathan Vahrenberg on 11/20/15.
//  Copyright © 2015 Christopher Ray. All rights reserved.
//

import Foundation
import CoreLocation


class SettingsViewController: UITableViewController, CLLocationManagerDelegate
{
    var userRef: Firebase!
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var location:CLLocationCoordinate2D!
    var pairondistance = 1
    var paironinterest = 1

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
   
    
    @IBAction func InterestSwitch(sender: AnyObject) {
        if self.paironinterest == 1{
            self.paironinterest = 0
        } else {
            self.paironinterest = 1
        }
    }
    
    @IBAction func RangeSwitch(sender: AnyObject) {
        
        if staticRangeText.textColor == UIColor.lightGrayColor(){
            staticRangeText.textColor = UIColor.blackColor()
            rangetext.textColor = UIColor.blackColor()
            self.pairondistance = 1
        } else {
            staticRangeText.textColor = UIColor.lightGrayColor()
            rangetext.textColor = UIColor.lightGrayColor()
            self.pairondistance = 0
        }
        
    }
    
    func insertNewUser(){
        userRef = Firebase(url: "https://incandescent-torch-8912.firebaseio.com/users")
        
        // Generate unique userID
        
        let userID = String(Int(NSDate().timeIntervalSinceReferenceDate) + rand())
        
        //
        print(userID)
        
        var i1 = ""
        if (!interest1.text!.isEmpty){
            i1 = interest1.text!
        }
        
        var i2 = ""
        if (!interest2.text!.isEmpty){
            i2 = interest2.text!
        }
        
        var i3 = ""
        if (!interest3.text!.isEmpty){
            i3 = interest3.text!
        }
        
        var n = "Anonymous"
        if (!codename.text!.isEmpty){
            n = codename.text!
        }
        
        userRef.childByAppendingPath(userID).setValue([
            "codename":  n,
            "interest1": i1,
            "interest2": i2,
            "interest3": i3,
            "buddy": "",
            "paired": 0,
            "latitude": self.latitude,
            "longitude": self.longitude])
        
        pairUsers()
    }
    
    func pairUsers(){
        performSegueWithIdentifier("toFireChat", sender: self)
        
    }
    
    @IBAction func ButtonPressed(sender: UIBarButtonItem) {
        
        insertNewUser()
        // SEND USER & PAIRED USER INFO TO NEXT VIEW
            
        //performSegueWithIdentifier("toFireChat", sender: self)
    }

    @IBAction func rangevaluechanged(sender: UISlider) {
        let currentvalue = Int(sender.value)
        rangetext.text = String(currentvalue)
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codename.text = "Anonymous"
        rangetext.text = "500"
        interest1.text = ""
        interest2.text = ""
        interest3.text = ""
        
        
        self.locationManager = CLLocationManager()  //initializing location manager
        
        //self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    @objc func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        
        self.latitude = self.locationManager.location!.coordinate.latitude
        self.longitude = self.locationManager.location!.coordinate.longitude

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}