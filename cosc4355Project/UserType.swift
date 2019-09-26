//
//  UserType.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

enum UserType {
  case client
  case contractor
  
  static func stringToEnum(string: String) -> UserType {
    switch string {
    case "Client":
      return client
    case "Contractor":
      return contractor
    default:
      return client
    }
  }
}
