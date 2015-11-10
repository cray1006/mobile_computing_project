//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import Foundation
import CoreLocation

class Message : NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    var latitude_: CLLocationDegrees?
    var longitude_: CLLocationDegrees?
    
    convenience init(text: String?, sender: String?)
    {
        self.init(text: text, sender: sender, imageUrl: nil, latitude: 0, longitude: 0)
    }
    
    init(text: String?, sender: String?, imageUrl: String?, latitude: CLLocationDegrees?, longitude: CLLocationDegrees?)
    {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
        self.latitude_ = latitude!
        self.longitude_ = longitude!
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
    
    func latitude() -> CLLocationDegrees?
    {
        return latitude_;
    }
    
    func longitude() -> CLLocationDegrees?
    {
        return longitude_;
    }
}