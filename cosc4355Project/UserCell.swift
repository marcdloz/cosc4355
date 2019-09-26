//
//  UserCell.swift
//  gameofchats
//
//  Created by Brian Voong on 7/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
  
  var message: Message? {
    didSet {
      setupNameAndProfileImage()
      
      secondaryLabel?.text = message?.text
      
      if let seconds = message?.timestamp?.doubleValue {
        let timestampDate = Date(timeIntervalSince1970: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = dateFormatter.string(from: timestampDate)
      }
    }
  }
  
  fileprivate func setupNameAndProfileImage() {
    
    if let id = message?.chatPartnerId() {
      let ref = Database.database().reference().child("users").child(id)
      ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
          self.mainLabel?.text = dictionary["name"] as? String
          
          if let profileImageUrl = dictionary["profilePicture"] as? String {
            self.profileImageView.loadImage(url: profileImageUrl)
          }
        }
        
      }, withCancel: nil)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
 
    profileImageView.layer.cornerRadius = 24
    profileImageView.layer.masksToBounds = true
  }
  
  @IBOutlet weak var profileImageView: CustomImageView!
  
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var mainLabel: UILabel!
  
  @IBOutlet weak var secondaryLabel: UILabel!
  
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    addSubview(timeLabel)
    
    //ios 9 constraint anchors
    //need x,y,width,height anchors
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    
    //need x,y,width,height anchors
    timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
    timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
