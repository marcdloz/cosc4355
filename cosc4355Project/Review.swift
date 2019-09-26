//
//  Review.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Review {
    
    var reviewId: String

    var user_id: String
    var about_id: String
    var posting_id: String
    
    var stars: Int
    //var reviewTitle: String
    var reviewWords: String
    var reviewTime: String
    
    // Default Address
    init(about_id: String, posting_id: String, stars: Int, reviewWords: String, reviewTime: String)
    {
        self.reviewId = "DEFAULT"
        
        self.user_id = "DEFAULT"
        self.about_id = about_id
        self.posting_id = posting_id
        
        self.stars = stars
        //self.reviewTitle = reviewTitle
        self.reviewWords = reviewWords
        self.reviewTime = Date.currentDate
    }
  
    init(from dictionary: [String: Any]) {
        reviewId = "DEFAULT"
        
        user_id = dictionary["user_id"] as! String
        about_id = dictionary["about_id"]! as! String
        posting_id = dictionary["posting_id"]! as! String
        
        stars = dictionary["stars"]! as! Int
        reviewTime = dictionary["reviewTime"]! as! String
        //reviewTitle = dictionary["reviewTitle"]! as! String
        reviewWords = dictionary["reviewWords"]! as! String
    }
    
    func toString() -> String {
        return user_id + " gave rating " + String(stars) + " on " + String(describing: reviewTime) + " for user " + about_id + " and said:\n" + reviewWords
    }
}
