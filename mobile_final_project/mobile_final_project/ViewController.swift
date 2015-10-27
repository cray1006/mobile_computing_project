//
//  ViewController.swift
//  mobile_final_project
//
//  Created by Christopher Ray on 10/27/15.
//  Copyright © 2015 Christopher Ray. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var receiveText: UILabel!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://incandescent-torch-8912.firebaseio.com/")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageText.delegate = self
        // Write data to Firebase
        self.myRootRef.setValue("Do you have data? You'll love Firebase.")
        
        // Read data and react to changes
        self.myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.receiveText.text = ("\(snapshot.key) -> \(snapshot.value)")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        messageText.resignFirstResponder()
        return true
    }
    
    @IBAction func sendData(sender: UIButton)
    {
        self.myRootRef.setValue(self.messageText.text)
    }
}

