//
//  Notification_Tests.swift
//  cosc4355ProjectTests
//
//  Created by Timothy M Shepard on 12/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
@testable import cosc4355Project


class Notification_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotification(){
        NotificationsUtil.notify(notifier_id: "testing", notified_id: "testing", posting_id: "testing", notificationId:"testing", notificationType: "test", notifier_name: "testing", notifier_image: "",posting_name: "testing")
        
        XCTAssertTrue(true)
        
    }
    
}
