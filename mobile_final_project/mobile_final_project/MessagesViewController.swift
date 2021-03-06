//
//  MessagesViewController.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/13/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Darwin

class MessagesViewController: JSQMessagesViewController, CLLocationManagerDelegate
{
    var user: FAuthData?
    
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    var locationManager: CLLocationManager!
    var userID: String!
    var codeName:  String!
    var buddyID: String!
    var buddy:  String!
    var temp_buddy:  String!
    var range:  Double!
    var min_d:  Double!
    var latitude:  CLLocationDegrees!
    var longitude:  CLLocationDegrees!

    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    var userRef: Firebase!

    func setupFirebase() {
        // STEP 2: SETUP FIREBASE
        messagesRef = Firebase(url: "https://incandescent-torch-8912.firebaseio.com/messages")
        userRef = Firebase(url: "https://incandescent-torch-8912.firebaseio.com/users")
        
        

        // RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.queryLimitedToNumberOfChildren(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let text = snapshot.value["text"] as? String
            let sender = snapshot.value["sender"] as? String
            let imageUrl = snapshot.value["imageUrl"] as? String
            
            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            
            //only display messages from your buddy
            if((sender == self.buddyID) || (sender == self.userID))
            {
                 self.messages.append(message)
            }
            
            //delete un-needed user information for users who are already paired
            self.userRef.childByAppendingPath(sender).removeValue()
            self.finishReceivingMessage()
        })

    }
    
    
    func sendMessage(text: String!, sender: String!)
    {
        // ADD A MESSAGE TO FIREBASE
        messagesRef.childByAutoId().setValue([
            "text":text,
            "sender":sender,
            "imageUrl":senderImageUrl,
        ])
    }
    
    
    func tempSendMessage(text: String!, sender: String!)
    {
        let message = Message(text: text, sender: sender, imageUrl: senderImageUrl)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool)
    {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool)
    {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        var nameLength = 0
        var initials : String? = ""
        
        //display codeName initials in avatar bubbles
        if(name == userID)
        {
            nameLength = codeName.characters.count
            initials = codeName.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        }
        else
        {
            nameLength = buddy.characters.count
            initials = buddy.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        }
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Pen Pal"
        
        //sender = (sender != nil) ? sender : "Anonymous"
        sender = userID
        let profileImageUrl = user?.providerData["cachedUserProfile"]?["profile_image_url_https"] as? NSString
        if let urlString = profileImageUrl {
            setupAvatarImage(sender, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(sender, incoming: false)
            senderImageUrl = ""
        }
        
        setupFirebase()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = true
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if ref != nil {
            ref.unauth()
        }
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem)
    {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!)
    {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        sendMessage(text, sender: userID)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!)
    {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView!
    {
        let message = messages[indexPath.item]
        
        if message.sender() == sender
        {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView!
    {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()]
        {
            return UIImageView(image: avatar)
        }
        else
        {
            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender
        {
            cell.textView!.textColor = UIColor.whiteColor()
        }
        else
        {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView!.linkTextAttributes = attributes
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sender() == sender
        {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender()
            {
                return nil;
            }
        }
        
        //return NSAttributedString(string:message.sender())
        return NSAttributedString(string:buddy)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender() == sender
        {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0
        {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
