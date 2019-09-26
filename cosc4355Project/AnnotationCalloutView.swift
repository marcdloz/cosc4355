//
//  AnnotationCalloutView.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 12/11/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class AnnotationCalloutView: UIView {
    
    @IBOutlet weak var projectTitleLabel: UILabel!
    
    @IBOutlet weak var projectDescription: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        distanceLabel.layer.cornerRadius = 10.0
        distanceLabel.clipsToBounds = true
    }
    
    func setRatingImage(rating : Int)
    {
        if(rating == 0){
            ratingImage.image = UIImage(named: "0stars")
        }
        else if(rating == 1){
            ratingImage.image = UIImage(named: "1stars")
        }
        else if(rating == 2){
            ratingImage.image = UIImage(named: "2stars")
        }
        else if(rating == 3){
            ratingImage.image = UIImage(named: "3stars")
        }
        else if(rating == 4){
            ratingImage.image = UIImage(named: "4stars")
        }
        else if(rating == 5){
            ratingImage.image = UIImage(named: "5stars")
        }
    }
    
}
