//
//  SettingsViewController.swift
//  mobile_final_project
//
//  Created by Nathan Vahrenberg on 11/20/15.
//  Copyright © 2015 Christopher Ray. All rights reserved.
//

import Foundation

class SettingsViewController: UITableViewController
{

    @IBOutlet weak var toggle1: UISwitch!
    @IBOutlet weak var toggle2: UISwitch!
    @IBOutlet weak var rangeslider: UISlider!
    @IBOutlet weak var rangetext: UILabel!
    @IBOutlet weak var interest1: UITextField!
    @IBOutlet weak var interest2: UITextField!
    @IBOutlet weak var confirmbutton: UIBarButtonItem!
    @IBOutlet weak var interest3: UITextField!
    @IBOutlet weak var codename: UITextField!
    

    @IBAction func rangevaluechanged(sender: UISlider) {
        let currentvalue = Int(sender.value)
        rangetext.text = String(currentvalue)
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        rangetext.text = "500"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}