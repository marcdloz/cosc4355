//
//  UsersList.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 11/2/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import Firebase

/* Singleton class for all users */
class UsersList {
  private static var users = [String: User]()
  static func getUsers() -> [String: User] {
    if users.count == 0 {
      fetchUsers()
      print("Fetch")
    }
    return users
  }
  
  static func fetchUsers() {
    let rootRef = Database.database().reference().child("users")
    rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
      guard let dictionaries = FIRDataSnapshot.value as? [String: AnyObject] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        let user = User(from: dictionary, id: key)
        self.users[key] = user
      })
    }) { (error) in
      print("Failed retrieving user projects with error: \(error)")
    }
  }
}
