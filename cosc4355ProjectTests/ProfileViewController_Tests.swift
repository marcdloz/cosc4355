//
//  ProfileViewController_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project

class ProfileViewController_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let profileVC = ProfileViewController()
    
    func test_InitProfileViewController()
    {
        XCTAssertEqual(profileVC.didSegueHere, false)
        XCTAssertEqual(profileVC.cameFromBids, false)
        XCTAssertEqual(profileVC.currentUserId, "")
        
        XCTAssertTrue(profileVC.profilePicture is CustomImageView!, "Correct")
        XCTAssertTrue(profileVC.nameLabel is UILabel!, "Correct")
        XCTAssertTrue(profileVC.emailLabel is UILabel!, "Correct")
        XCTAssertTrue(profileVC.reviewsTableView is UITableView!, "Correct")
        
        XCTAssert(profileVC.reviews is [Review])
        XCTAssert(profileVC.reviewersPhotos is [String:String])
        
        XCTAssert(profileVC.logoutOutlet is UIButton!)
    }
    
    
    
}
