//
//  Status.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

enum Status {
  case pending
  case inProgress
  case completed
  
  static func stringToEnum(string: String) -> Status {
    switch string {
    case "pending":
      return pending
    case "inProgress":
      return inProgress
    case "completed":
      return completed
    default:
      return completed
    }
  }
}
