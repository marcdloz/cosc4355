//
//  Notification.swift
//  cosc4355Project
//
//  Created by gintama on 10/16/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation

struct Notifications {
  var notification_key: String
  var notification_id: String
  var notified_id: String
  var notifier_id: String
  var posting_id: String
  var notificationType: NotificationType
  var expectedTime: String
  var notifier_name: String
  var project_name: String
  var notifier_image: String
  
  init(from dict: [String: Any], id: String) {
    notification_key = dict["notification_key"] as? String ?? ""
    notified_id = dict["notified_id"] as? String ?? ""
    notifier_id = dict["notifier_id"] as? String ?? ""
    posting_id = dict["posting_id"] as? String ?? ""
    expectedTime = dict["expectedTime"] as? String ?? ""
    notificationType = NotificationType.stringToEnum(string: dict["notificationType"] as? String ?? "")
    notification_id = id
    notifier_name = dict["notifier_name"] as? String ?? ""
    project_name = dict["posting_name"] as? String ?? ""
    notifier_image = dict["notifier_image"] as? String ?? ""  }
}
