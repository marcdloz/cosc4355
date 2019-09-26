//
//  ViewController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MessagesController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("TEST")
    checkIfUserIsLoggedIn()
    tableView.allowsMultipleSelectionDuringEditing = true
  }

  @IBAction func backButton(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func checkIfUserIsLoggedIn() {
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    } else {
      print("test2")
      fetchUserAndSetupNavBarTitle()
      print("test1")
    }
  }
  
  @objc func handleLogout() {
    do {
      try Auth.auth().signOut()
    } catch let logoutError {
      print(logoutError)
    }
    dismiss(animated: true, completion: nil)
  }
  
  // For deleting messages
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let message = self.messages[indexPath.row]
    
    if let chatPartnerId = message.chatPartnerId() {
      Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
        
        if error != nil {
          print("Failed to delete message:", error!)
          return
        }
        
        self.messagesDictionary.removeValue(forKey: chatPartnerId)
        self.attemptReloadOfTable()
      })
    }
  }
  
  var messages = [Message]()
  var messagesDictionary = [String: Message]()
  
  func observeUserMessages() {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let ref = Database.database().reference().child("user-messages").child(uid)
    ref.observe(.childAdded, with: { (snapshot) in
      
      let userId = snapshot.key
      Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
        
        let messageId = snapshot.key
        self.fetchMessageWithMessageId(messageId)
        
      }, withCancel: nil)
      
    }, withCancel: nil)
    
    ref.observe(.childRemoved, with: { (snapshot) in
      print(snapshot.key)
      print(self.messagesDictionary)
      
      self.messagesDictionary.removeValue(forKey: snapshot.key)
      self.attemptReloadOfTable()
      
    }, withCancel: nil)
  }
  
  fileprivate func fetchMessageWithMessageId(_ messageId: String) {
    let messagesReference = Database.database().reference().child("messages").child(messageId)
    
    messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: AnyObject] {
        let message = Message(dictionary: dictionary)
        
        if let chatPartnerId = message.chatPartnerId() {
          self.messagesDictionary[chatPartnerId] = message
        }
        
        self.attemptReloadOfTable()
      }
      
    }, withCancel: nil)
  }
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  var timer: Timer?
  
  @objc func handleReloadTable() {
    self.messages = Array(self.messagesDictionary.values)
    self.messages.sort(by: { (message1, message2) -> Bool in
      
      return message1.timestamp?.int32Value > message2.timestamp?.int32Value
    })
    
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.tableView.reloadData()
    })
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
    
    let message = messages[indexPath.row]
    cell.message = message
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    
    guard let chatPartnerId = message.chatPartnerId() else {
      return
    }
    
    let ref = Database.database().reference().child("users").child(chatPartnerId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else {
        return
      }
      
      let user = User(from: dictionary, id: snapshot.key)
      user.id = chatPartnerId
      self.showChatControllerForUser(user)
      
    }, withCancel: nil)
  }
  
  func handleNewMessage() {
    let newMessageController = NewMessageController()
    newMessageController.messagesController = self
    let navController = UINavigationController(rootViewController: newMessageController)
    present(navController, animated: true, completion: nil)
  }
  
  func fetchUserAndSetupNavBarTitle() {
    guard let uid = Auth.auth().currentUser?.uid else {
      //for some reason uid = nil
      return
    }
    
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: Any] {
        //                self.navigationItem.title = dictionary["name"] as? String
        
        let user = User(from: dictionary, id: snapshot.key)
        self.setupNavBarWithUser(user)
      }
      
    }, withCancel: nil)
  }
  
  func setupNavBarWithUser(_ user: User) {
    messages.removeAll()
    messagesDictionary.removeAll()
    tableView.reloadData()
    
    observeUserMessages()
    
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    //        titleView.backgroundColor = UIColor.redColor()
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)
    
    let profileImageView = CustomImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 20
    profileImageView.clipsToBounds = true
    if let profileImageUrl = user.profilePicture {
      profileImageView.loadImage(url: profileImageUrl)
    }
    print("testphoto2")
    containerView.addSubview(profileImageView)
    
    //ios 9 constraint anchors
    //need x,y,width,height anchors
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    let nameLabel = UILabel()
    
    containerView.addSubview(nameLabel)
    nameLabel.text = user.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    //need x,y,width,height anchors
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
    self.navigationItem.titleView = titleView
    
    //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
  }
  
  func showChatControllerForUser(_ user: User) {
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.user = user
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
}

