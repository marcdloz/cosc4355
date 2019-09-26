//
//  AcceptedBidViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/23/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class AcceptedBidViewController: UIViewController {
  
  var userId: String = ""
  var user: User? = nil
  var bid: Bid? = nil
  var posting: Posting? = nil
  var cameFromBid = false
  
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var userImage: CustomImageView!
  
  // @IBOutlet weak var ratingLabel: UILabel!
  
  @IBOutlet weak var contactInfoLabel: UILabel!
  
    @IBAction func review(_ sender: UIButton) {
        
        let reviewsCollection = ReviewsForUserCollector(user_id: (bid?.bidder_id)!)
        
        reviewsCollection.checkIfUserAlreadyReviewed(posting_id_ToCheck: (posting?.posting_id)!, completion: { (success) in
            var doSegue = true
            
            if success {
                doSegue = !reviewsCollection.alreadyReviewedForPosting
            } else {
                print ("Error finding if posting already has review for bidder.")
            }
            
            if doSegue {
                self.performSegue(withIdentifier: "reviewSegue", sender: self)
            } else {
                self.alreadyReviewedUserForThisPosting()
            }
        })
    }
  
  @IBAction func pay(_ sender: UIButton) {
    print("PAY")
   
    let alertController = UIAlertController(title: "Pay", message: "Enter amount to pay", preferredStyle: .alert)
    let payAction = UIAlertAction(title: "Pay", style: .default) { (_: UIAlertAction) in
      NotificationsUtil.notify(notifier_id: Auth.getCurrentUserId(), notified_id: (self.user?.id)!, posting_id: (self.posting?.posting_id)!, notificationId: NSUUID().uuidString, notificationType: "paymentMade", notifier_name: (self.user?.name)!, notifier_image: (self.user?.profilePicture)!, posting_name: (self.posting?.title)!)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addTextField(configurationHandler: nil)
    alertController.addActions(actions: payAction, cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  func notifyPaid() {
    let notifier_id = Auth.getCurrentUserId()
    let notified_id = user?.id
    let posting_id = posting?.posting_id
    let notificationId = NSUUID().uuidString
    
    let values = ["notifier_id": notifier_id, "notified_id": notified_id, "notificationType": "paymentMade", "posting_id": posting_id, "expectedTime": Date.currentDate]
    self.registerInfoIntoDatabaseWithUID(uid: notificationId, values: values as [String: AnyObject])
    // self.navigationController?.popViewController(animated: true)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("Notification").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
    
    func alreadyReviewedUserForThisPosting() {
        let alert = UIAlertController(title: "Already Reviewed", message: "You already reviewed this user for this posting.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
  
  @IBAction func cancel(_ sender: UIButton) {
    print("CANCEL")
    let alertController = UIAlertController(title: "Confirm", message: "Cancel the user's bid?", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (_: UIAlertAction) in
      self.updateBidAcceptedInDB(bidAmount: "0", sender: nil)
       NotificationsUtil.notify(notifier_id: Auth.getCurrentUserId(), notified_id: (self.user?.id)!, posting_id: (self.posting?.posting_id)!, notificationId: NSUUID().uuidString, notificationType: "bidCancelled", notifier_name: (self.user?.name)!, notifier_image: (self.user?.profilePicture)!, posting_name: (self.posting?.title)!)
      self.navigationController?.popViewController(animated: true)
    }
    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
    alertController.addActions(actions: confirmAction, cancel)
    present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.topItem?.title = "Projects"
    self.navigationItem.title = posting?.title
    
    userImage.layer.masksToBounds = true
    userImage.layer.cornerRadius = userImage.frame.size.height/2
    
    self.makeTapGestureForProfileSegue(userPhoto: userImage)
    
    fetchUserInfo()
    
    let reviewsCollection = ReviewsForUserCollector(user_id: (self.bid?.bidder_id)!)
    reviewsCollection.calculateUserRating(completion: { (success) -> () in
        if success {
            print("Now average rating is: ", reviewsCollection.averageRating)
            var averageRatingString: NSString = ""
            if reviewsCollection.hasReviews {
                averageRatingString = NSString(format: "%.2f Stars Average", reviewsCollection.averageRating)
              
              self.bidderRating.image = UIImage(named: String(Int(reviewsCollection.averageRating)) + "stars")
              print(String(Int(reviewsCollection.averageRating)) + "stars")
            } else {
                averageRatingString = "No reviews yet."
              self.bidderRating.image = UIImage(named: "0stars")
            }
            // self.ratingLabel.text = String(averageRatingString)
        }
        else
        {
            print("Error retrieving averageRating")
        }
    })
  }
  
  @IBOutlet weak var bidderRating: UIImageView!
  
  
  func fetchUserInfo() {
    Database.database().reference().child("users/\(bid?.bidder_id ?? "")").observeSingleEvent(of: .value, with: { (snap) in
      guard let dictionary = snap.value as? [String: Any] else { return }
      self.user = User(from: dictionary, id: (self.bid?.bidder_id)!)
      self.nameLabel.text = (self.user?.name)! + " • " + Double.getFormattedCurrency(num: (self.bid?.bidAmount)!)
      self.userImage.loadImage(url: (self.user?.profilePicture) ?? "")
      // self.ratingLabel.text = "5 Star"
      self.contactInfoLabel.text = self.user?.email
    })
  }
  
  func updateBidAcceptedInDB(bidAmount: String, sender: UIButton?) {
    let values = ["acceptedBid": bidAmount] as [String : Any]
    self.registerInfoIntoDatabaseWithUID(uid: (posting?.posting_id)!, values: values as [String: AnyObject], sender: sender)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject], sender: UIButton?) {
    let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let bidsReference = ref.child("projects").child(uid)
    bidsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  override func willMove(toParentViewController parent:UIViewController?) {
    super.willMove(toParentViewController: parent)
    if (parent == nil && cameFromBid) {
      if let navigationController = self.navigationController {
        var viewControllers = navigationController.viewControllers
        let viewControllersCount = viewControllers.count
        if (viewControllersCount > 2) {
          viewControllers.remove(at: viewControllersCount - 2)
          navigationController.setViewControllers(viewControllers, animated:false)
        }
      }
      cameFromBid = false
    }
  }
    
    func makeTapGestureForProfileSegue(userPhoto: CustomImageView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action :#selector(userImageTapped(tapGestureRecognizer:)))
        userPhoto.isUserInteractionEnabled = true
        userPhoto.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func userImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        //print("Accepted Bid Contractor Image was tapped.")
        performSegue(withIdentifier: "acceptedBidToProfile", sender: self)
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "reviewSegue" {
      let dvc = segue.destination as! ReviewFormViewController
      dvc.aboutUser = user
      dvc.bid = bid
      dvc.project = posting
    }
    if segue.identifier == "acceptedBidToProfile" {
        let dvc = segue.destination as! ProfileViewController
        dvc.didSegueHere = true
        dvc.currentUserId = (user?.id)! 
        dvc.cameFromBids = false
    }
  }
}
