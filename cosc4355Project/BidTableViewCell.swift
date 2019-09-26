//
//  BidTableViewCell.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class BidTableViewCell: UITableViewCell {
  
  @IBOutlet weak var bidderPhoto: CustomImageView! {
    didSet {
      bidderPhoto.layer.masksToBounds = true
      bidderPhoto.layer.cornerRadius = bidderPhoto.layer.frame.height / 2
    }
  }
  
  @IBOutlet weak var bidderName: UILabel!
  
  @IBOutlet weak var bidderRating: UIImageView!
  
  @IBOutlet weak var bidderBid: UILabel!
  
  var isAccepted = false
 
  @IBOutlet weak var acceptButton: UIButton! {
    didSet {
      acceptButton.layer.masksToBounds = true
      acceptButton.layer.cornerRadius = 10
      acceptButton.layer.borderWidth = 1
      acceptButton.layer.borderColor = acceptButton.titleLabel?.textColor.cgColor
    }
  }

  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
