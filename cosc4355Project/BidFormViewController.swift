//
//  BidFormViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/10/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class BidFormViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var posterImage: UIImageView!
  
  @IBOutlet weak var projectTitle: UILabel!
  
  @IBOutlet weak var projectImage: UIImageView!
  
  @IBOutlet weak var projectDescription: UILabel!
  
  @IBOutlet weak var bidAmountField: UITextField!
  
  @IBOutlet weak var bidButton: UIButton!
  
  var projectTitleString: String?
  
  @IBOutlet weak var ownerTitle: UILabel!
  
  var ownerTitleHolder: String?
  
  var projectDescriptionString: String?
  
  var projectImagePhoto: UIImage?
  
  var posterImagePhoto: UIImage?
  
  var currentUser:User? = nil
  
  var postingId: String?
  var userWhoPostedId: String?
  
  var userWhoPosted: User?
  var posting: Posting?
  
  var bidAmountFieldIsHidden = false
  var bidButtonisHidden = false
  
  
  
  @IBAction func makeBid(_ sender: UIButton) {
    guard let bidAmount = bidAmountField.text, let user_id = userWhoPostedId, let posting_id = postingId else { return }
    
    let bidId = NSUUID().uuidString
    let values = ["bidAmount": bidAmount, "expectedTime": Date.currentDate, "user_id": user_id, "bidder_id": Auth.getCurrentUserId(), "posting_id": posting_id, "id": bidId]
    self.registerInfoIntoDatabaseWithUID(uid: bidId, values: values as [String: AnyObject])
    
    NotificationsUtil.notify(notifier_id: Auth.getCurrentUserId(), notified_id: user_id, posting_id: posting_id, notificationId: NSUUID().uuidString, notificationType: "bidOffered", notifier_name: (self.currentUser?.name)!, notifier_image: (self.currentUser?.profilePicture)!,posting_name: projectTitleString!)
    
    self.navigationController?.popViewController(animated: true)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("bids").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  func fetchForCertainId(child: String, id: String) {
    Database.database().reference().child(child).child(id).observeSingleEvent(of: .value, with: { (snap) in
      guard let dictionary = snap.value as? [String: Any] else { return }
      switch child {
      case "users":
        self.userWhoPosted = User(from: dictionary, id: snap.key)
      case "projects":
        self.posting = Posting(from: dictionary)
      default:
        print("This shouldn't happen - fetchForCertainId()")
      }
    })
  }
  
  func fetchUserInfo() {
    Database.database().reference().child("users/\(Auth.getCurrentUserId())").observeSingleEvent(of: .value, with: { (snap) in
      guard let dictionary = snap.value as? [String: Any] else { return }
      self.currentUser = User(from: dictionary, id: (Auth.getCurrentUserId()))
      
    })
  }
  
  func makeTapGestureForProfileSegue(userPhoto: UIImageView) {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action :#selector(userImageTapped(tapGestureRecognizer:)))
    userPhoto.isUserInteractionEnabled = true
    userPhoto.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func userImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
    performSegue(withIdentifier: "bidFormProfile", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "bidFormProfile" {
      let dvc = segue.destination as! ProfileViewController
      dvc.didSegueHere = true
      dvc.currentUserId = userWhoPostedId!
      dvc.cameFromBids = true
    }
  }
  
  @objc func dismissKb() {
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchUserInfo()
    fetchForCertainId(child: "users", id: userWhoPostedId ?? "")
    fetchForCertainId(child: "projects", id: postingId ?? "")
    bidAmountField.delegate = self
    
    bidButton.isHidden = bidButtonisHidden
    bidAmountField.isHidden = bidButtonisHidden
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
    view.addGestureRecognizer(tap)
    
    posterImage.layer.masksToBounds = true
    posterImage.layer.cornerRadius = 27
    projectTitle.text = projectTitleString ?? "DEFAULT TITLE"
    projectDescription.text = projectDescriptionString ?? "DEFAULT DESC"
    projectImage.image = projectImagePhoto!
    posterImage.image = posterImagePhoto!
    ownerTitle.text = ownerTitleHolder ?? "DEFAULT OWNER"
    
    makeTapGestureForProfileSegue(userPhoto: projectImage)
    // print(postingId ?? "empty1")
    // print(userWhoPostedId ?? "empty2")
  }
  
  
}
