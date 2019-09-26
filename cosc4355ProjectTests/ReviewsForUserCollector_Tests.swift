//
//  ReviewsForUserCollector_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/9/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project

class ReviewsForUserCollector_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //  ********** Init Tests **********
    

    func testInit_ShouldTake_user_id()
    {
        let reviewsCollector = ReviewsForUserCollector(user_id: "IDIDID")
        XCTAssertEqual(reviewsCollector.user_id, "IDIDID")
        //XCTAssertTrue(reviewsCollector.reviewsForUser[0] == nil, "no reviews")
        XCTAssertEqual(reviewsCollector.averageRating, 0.0)
        XCTAssertEqual(reviewsCollector.hasReviews, false)
        XCTAssertEqual(reviewsCollector.alreadyReviewedForPosting, false)
    }
    
    func test_UserHasReviewForPostingAlready()
    {
        let reviewsCollector = ReviewsForUserCollector(user_id: "TXgWmv0492TFD1WNqWFUza33uGi2")
        
        reviewsCollector.checkIfUserAlreadyReviewed(posting_id_ToCheck: "904485F5-CF6C-4F64-92C6-C79F4EEB4A10", completion:
            { (success) in
                XCTAssertTrue(success == true, "Failed check has review.")
        })
        
        reviewsCollector.checkIfUserAlreadyReviewed(posting_id_ToCheck: "FAKEFAKEFAKE", completion:
            { (success) in
                XCTAssertTrue(success == false, "Failed check has review.")
        })
    }
    
    func test_calculateUserRating()
    {
        let reviewsCollector = ReviewsForUserCollector(user_id: "tKZ21YZ0fYR3Hm8XKlwGc5i1vyn2") // User Michael Moreno
        
        reviewsCollector.calculateUserRating(completion:
            { (success) in
                XCTAssertTrue(reviewsCollector.averageRating == 4.5, "Correct rating should be 4.5")
        })
    }
    
    
    //func test_getAllReviewsForUser()
    //{
    //    let reviews
    //}
 
}
