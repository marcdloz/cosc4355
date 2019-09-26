//
//  ReviewsTableViewCell_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project

class ReviewsTableViewCell_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_InitReviewTableViewCell()
    {
        let reviewCell = ReviewTableViewCell()
        
        XCTAssert(reviewCell.starsImage is UIImageView!)
        XCTAssert(reviewCell.reviewWordsLabel is UILabel!)
        XCTAssert(reviewCell.reviewerPhoto is CustomImageView!)
        
        XCTAssert(reviewCell.posting_id is String?)
        XCTAssert(reviewCell.user_id is String?)
    }
    
    
}
