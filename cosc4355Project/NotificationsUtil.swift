//
//  NotificationsUtil.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/24/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import Firebase

class NotificationsUtil {
  static func notify(notifier_id: String, notified_id: String, posting_id: String, notificationId: String, notificationType: String, notifier_name: String, notifier_image: String, posting_name: String) {
    let values = ["notification_key": notificationId,"notifier_id": notifier_id, "notified_id": notified_id, "notificationType": notificationType, "posting_id": posting_id, "expectedTime": Date.currentDate, "notifier_name": notifier_name, "notifier_image": notifier_image, "posting_name": posting_name]
    self.registerInfoIntoDatabaseWithUID(uid: notificationId, values: values as [String: AnyObject])
  }
  
  static private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("Notification").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
}
