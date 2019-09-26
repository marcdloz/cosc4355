//
//  Review_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project


class Review_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Init_Review()
    {
        let review = Review(about_id: "Somebody", posting_id: "Some posting", stars: 4, reviewWords: "Review Words", reviewTime: "2017")
        XCTAssertEqual(review.reviewId, "DEFAULT")
        XCTAssertEqual(review.user_id, "DEFAULT")
        XCTAssertEqual(review.about_id, "Somebody")
        XCTAssertEqual(review.posting_id, "Some posting")
        XCTAssertEqual(review.stars, 4)
        XCTAssertEqual(review.reviewWords, "Review Words")
        XCTAssertEqual(review.reviewTime, Date.currentDate)
    }
    
    func test_InitFromDictionary_Review()
    {
        let review = Review(from: ["user_id": "SomeB", "about_id": "Jumpman", "reviewWords": "some guy", "posting_id":"009323", "stars": 2, "reviewTime": "Now"])
        XCTAssertEqual(review.reviewId, "DEFAULT")
        XCTAssertEqual(review.user_id, "SomeB")
        XCTAssertEqual(review.about_id, "Jumpman")
        XCTAssertEqual(review.posting_id, "009323")
        XCTAssertEqual(review.stars, 2)
        XCTAssertEqual(review.reviewWords, "some guy")
        XCTAssertEqual(review.reviewTime, "Now")
    }

}
