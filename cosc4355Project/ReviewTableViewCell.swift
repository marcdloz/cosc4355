//
//  ReviewTableViewCell.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    //@IBOutlet weak var userPhoto: CustomImageView!
    @IBOutlet weak var starsImage: UIImageView!
    @IBOutlet weak var reviewWordsLabel: UILabel!
    //@IBOutlet weak var bidderPhoto: CustomImageView!
    @IBOutlet weak var reviewerPhoto: CustomImageView!

    var posting_id: String?
    var user_id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posting_id = "DEFAULT"
        user_id = "DEFAULT"
        reviewerPhoto.layer.cornerRadius = self.reviewerPhoto.bounds.size.height / 2
        reviewerPhoto.layer.masksToBounds = true
        //self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        //self.profileImageView.clipsToBounds = YES;
        //starsLabel.text = "Review Stars"
        starsImage.image = UIImage(named: "0stars")
        reviewWordsLabel.text = "Review Words"
        print("is set")
        
    }
    

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
