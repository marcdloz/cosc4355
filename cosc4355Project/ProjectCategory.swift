//
//  ProjectCategory.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

enum ProjectCategory {
  case general
  case plumbing
  case gardening
  
  static func stringToEnum(string: String) -> ProjectCategory {
    switch string {
    case "general":
      return general
    case "plumbing":
      return plumbing
    case "gardening":
      return gardening
    default:
      return general
    }
  }
}
