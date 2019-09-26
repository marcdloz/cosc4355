//
//  ReviewViewController_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project

class ReviewViewController_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_InitReviewViewController()
    {
        let reviewVC = ReviewViewController()
        
        XCTAssert(reviewVC.stars is Int?)
        XCTAssert(reviewVC.reviewWords is String?)
        XCTAssert(reviewVC.reviewerPhotoString is String?)
        XCTAssert(reviewVC.arrivedAfterProfileSegue == false)
        XCTAssert(reviewVC.starsImage is UIImageView!)
        XCTAssert(reviewVC.reviewWordsLabel is UILabel!)
        XCTAssert(reviewVC.reviewerPhoto is CustomImageView!)
        XCTAssert(reviewVC.backButtonOutlet is UIButton!)
    }
    
}
