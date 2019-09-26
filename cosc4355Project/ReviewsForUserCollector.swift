//
//  CalculateUserRating.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 11/9/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import Firebase


//takes in user_id into constructor, has function to return average user rating

class ReviewsForUserCollector {
    
    var user_id: String
    var reviewsForUser: [Review]
    var averageRating: Double
    var hasReviews: Bool
    var alreadyReviewedForPosting: Bool
   
    
    init(user_id: String) {
        self.user_id = user_id
        self.reviewsForUser = []
        self.averageRating = 0.0
        self.hasReviews = false
        self.alreadyReviewedForPosting = false
    }
    
    
    func checkIfUserAlreadyReviewed(posting_id_ToCheck: String, completion: @escaping (Bool) -> ()) {
        self.getAllReviewsForUser(user_id: self.user_id, completion:  { (success) in
            if success {
                for review in self.reviewsForUser {
                    if review.posting_id == posting_id_ToCheck {
                        self.alreadyReviewedForPosting = true
                    }
                }
                completion(true)
            } else {
                print("Did not find posting, error loading reviews.")
            }
        })
    }
    

    func calculateUserRating(completion: @escaping (Bool) -> ()) {
        //print("Trying to calculate star rating for: ", user_id)
        
        self.getAllReviewsForUser(user_id: self.user_id, completion: { success in
            if success {
                var total_star_rating: Double = 0.0
                
                for review in self.reviewsForUser {
                    total_star_rating += Double(review.stars)
                }
                
                if self.reviewsForUser.count > 0 {
                    self.hasReviews = true
                    self.averageRating = total_star_rating/Double(self.reviewsForUser.count)
                }

                completion(true)
            }
            else {
                print("Did not get a rating, error loading reviews.")
            }
        })
    }
    

    
    
    func getAllReviewsForUser(user_id: String, completion: @escaping (Bool) -> ()) {
      Database.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let review = Review(from: dictionary)
                if review.about_id == user_id {
                    self.reviewsForUser.append(review)
                }
            })
            completion(true)  // use this in calling this function
        }) { (error) in
            print("Failed to fetch reviews with error: \(error)")
        }
    }
}
