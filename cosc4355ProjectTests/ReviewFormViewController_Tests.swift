//
//  ReviewFormViewController_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project

class ReviewFormViewController_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_InitReviewFormViewController()
    {
        let reviewFormVC = ReviewFormViewController()
        
        XCTAssertEqual(reviewFormVC.numStars, -1)
        XCTAssert(reviewFormVC.newReview is Review?)
        XCTAssert(reviewFormVC.project is Posting?)
        XCTAssert(reviewFormVC.aboutUser is User?)
        XCTAssert(reviewFormVC.bid is Bid?)
        XCTAssert(reviewFormVC.reviewWordsField is UITextView!)
        XCTAssert(reviewFormVC.stars1Outlet is UIButton!)
        XCTAssert(reviewFormVC.stars2Outlet is UIButton!)
        XCTAssert(reviewFormVC.stars3Outlet is UIButton!)
        XCTAssert(reviewFormVC.stars4Outlet is UIButton!)
        XCTAssert(reviewFormVC.stars5Outlet is UIButton!)
        
        XCTAssertEqual(reviewFormVC.username, "00498f92-df6f-4a8a-a7b7-6079c4ab31bf")
        XCTAssertEqual(reviewFormVC.password, "WdrGdeOvcXhe")
        XCTAssertEqual(reviewFormVC.version, "2016-12-07")
    }
    
    //func test_stars0Button()
    //{
    //    let reviewFormVC = ReviewFormViewController()
    //
    //    reviewFormVC.stars0Button(self)
    //
    //    XCTAssertEqual(reviewFormVC.numStars, 0)
    //}
    
    
    
    
}
