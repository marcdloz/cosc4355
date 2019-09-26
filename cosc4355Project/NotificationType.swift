//
//  File.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/24/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

enum NotificationType {
  case bidOffered
  case bidAccepted
  case bidCancelled
  case reviewMade
  case paymentMade
  
  static func stringToEnum(string: String) -> NotificationType{
    switch string {
    case "bidOffered":
      return bidOffered
    case "bidAccepted":
      return bidAccepted
    case "bidCancelled":
      return bidCancelled
    case "reviewMade":
      return reviewMade
    case "paymentMade":
      return paymentMade
    default:
      return bidOffered
    }
  }
}
