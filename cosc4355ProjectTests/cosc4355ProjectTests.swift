//
//  cosc4355ProjectTests.swift
//  cosc4355ProjectTests
//
//  Created by Ron Borneo on 12/7/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import XCTest
import Firebase
@testable import cosc4355Project

class cosc4355ProjectTests: XCTestCase {
    
  override func setUp() {
    
    super.setUp()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testGetFormattedCurrency() {
    XCTAssertEqual(Double.getFormattedCurrency(num: 10.03457), "$10.03")
    XCTAssertEqual(Double.getFormattedCurrency(num: 0012.03457), "$12.03")
    XCTAssertEqual(Double.getFormattedCurrency(num: 1000.301), "$1,000.30")
    XCTAssertEqual(Double.getFormattedCurrency(num: 9999.999), "$10,000.00")
    XCTAssertEqual(Double.getFormattedCurrency(num: 0.30), "$0.30")
  }
  func testNotification(){
        NotificationsUtil.notify(notifier_id: "testing", notified_id: "testing", posting_id: "testing", notificationId:"testing", notificationType: "testing", notifier_name: "testing", notifier_image: "",posting_name: "testing")
       let vc = NotificationViewController()
       vc.findNotification(notificationID:"testing",completion:{(success) in   XCTAssertTrue(success == true)})
       vc.deleteNotification(notificationID:"testing")
       vc.findNotification(notificationID:"testing",completion:{(success) in   XCTAssertTrue(success == false)})
    
   }
       
    func testLogin(){
        FirebaseApp.configure()
        var rightEmailAndPassword = false;
        var wrongEmailAndPassword = false;
        // correct email and password
        Auth.auth().signIn(withEmail:"abc@gmail.com", password:"abcdefg") { [unowned self] (user, error) in
            
            if let error = error {
                 // should not go to here, test fails if go to here
                XCTAssertTrue(rightEmailAndPassword == true)
            }else{
                  rightEmailAndPassword = true
                  XCTAssertTrue(rightEmailAndPassword == true)
                
            }
           }
    // wrong password
        Auth.auth().signIn(withEmail:"abc@gmail.com", password:"abcdefgkjhkjh") { [unowned self] (user, error) in
            
            if let error = error {
                wrongEmailAndPassword = true
                XCTAssertTrue(wrongEmailAndPassword == true)
               
            }else{
                // should not go to here, test fails if go to here
                XCTAssertTrue(wrongEmailAndPassword == true)
            }
        }
        
    }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
