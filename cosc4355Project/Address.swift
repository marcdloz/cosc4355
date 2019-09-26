//
//  File.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Address {
  var streetAddress: String
  var city: String
  var state: String
  var zipcode: String
  
  // Default Address
  init() {
    streetAddress = "1234 Fake Street"
    city = "Houston"
    state = "TX"
    zipcode = "21209"
  }
  
  func toString() -> String {
    return streetAddress + " - " + city + ", " + state + " " + zipcode
  }
}
