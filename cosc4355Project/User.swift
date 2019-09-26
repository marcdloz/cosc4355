//
//  User.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//


import Foundation
import UIKit

class User {
  var name: String = "DEFAULT"
  var email: String = "DEFAULT-EMAIL"
  // var address: Address
  var profilePicture: String?
  var userType: UserType = .client
  var id: String
  
  init(from dict: [String: Any], id: String) {
    name = dict["name"] as? String ?? "Def-Name"
    email = dict["email"] as? String ?? "Def-Email"
    profilePicture = dict["profilePicture"] as? String
    userType = UserType.stringToEnum(string: dict["userType"] as? String ?? "Client")
    self.id = id
  }
  init() {
    name = "DEFAULT"
    email = "DEFAULT-EMAIL"
    // var address: Address
    profilePicture = ""
    userType = .client
    id = ""
  }
}

class Contractor: User {
    var description: String = "DEFAULT"
    var phoneNumber: String = "NA"
}
