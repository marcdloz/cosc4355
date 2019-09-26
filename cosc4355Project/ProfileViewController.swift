//
//  ProfileViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var profilePicture: CustomImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    var didSegueHere: Bool = false
    //var segueUser: User?
    
    var reviews: [Review] = []
    
    var reviewersPhotos: [String: String] = [:]
    
    var currentUserId: String = ""
  
  
  @IBOutlet weak var logoutOutlet: UIButton!
  
  var cameFromBids = false
    
    
    @IBAction func logoutButton(_ sender: UIButton) {
        do {
          try Auth.auth().signOut()
            performSegue(withIdentifier: "logoutSegue", sender: self)
        } catch let error {
            print("Sign out failed: \(error)")
            return
        }
        print("Sign out successful")
    }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(true)
//    logoutOutlet.isHidden = cameFromBids ? true : false
//  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Profile"
        
        if didSegueHere {
            //currentUserID should be set now
            print("Just Segued here: currentUserId: ", currentUserId)
            //didSegueHere = false
            logoutOutlet.isHidden = true
        }
        else //user is looking at their own profile
        {
          currentUserId = Auth.getCurrentUserId()
            logoutOutlet.isHidden = false
        }
        
        /* Turns picture into a circle */
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
        profilePicture.layer.masksToBounds = true
        
        //Enable user to choose photo
        profilePicture.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUploadCurrentUser))
        profilePicture.addGestureRecognizer(tapGesture)
        
        fetchUserProfile()
        
        //self.registerFakeReviewsIntoDatabase()
        fetchReviews()
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self

        reviewsTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        reviewsTableView.rowHeight = 100
        reviewsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        /* Adding refresh feature on newsfeed to reload projects */
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        reviewsTableView.refreshControl = refreshControl

        let name = Notification.Name(rawValue: "updateFeed")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (_) in
            self.handleRefresh()
            self.fetchReviews()
        }
    }
    
    func fetchUserProfile() {
      Database.database().reference().child("users").child(currentUserId).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            let userValues = FIRDataSnapshot.value as? [String: AnyObject]
            self.nameLabel.text = userValues?["name"] as? String
            self.profilePicture.loadImage(url: (userValues?["profilePicture"] as? String) ?? "")
            self.emailLabel.text = userValues?["email"] as? String
            
            if self.didSegueHere
            {
                if let name = userValues?["name"] as? String
                {
                    self.navigationItem.title = name + "'s Profile"
                }
                else
                {
                    self.navigationItem.title = "Other User's Profile"
                }
            }
        })
    } // end fetchUserProfile
    
    
    func fetchReviewersPhotos() {
        for review in reviews {
          Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    if key == review.user_id {
                        let user = User()
                        user.profilePicture = dictionary["profilePicture"] as? String
                        user.name = (dictionary["name"] as? String)!
                        self.reviewersPhotos[key] = user.profilePicture
                    }
                })
                /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
                self.reviewsTableView.reloadData()
            })
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if reviewersPhotos.count > 0 {
            rowCount = reviews.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        reviews.sort(by: { (item1: Review, item2: Review) -> Bool in
                return Date.getDate(from: item1.reviewTime) > Date.getDate(from: item2.reviewTime)
            })

        let currentReview = reviews[indexPath.row]
        let starImageName = String(reviews[indexPath.row].stars) + "stars"
        cell.starsImage.image = UIImage(named: starImageName)
        cell.reviewWordsLabel.text = reviews[indexPath.item].reviewWords
        cell.reviewerPhoto.loadImage(url: reviewersPhotos[currentReview.user_id] ?? "")
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        
        
        return cell
    }
    

        
    /* Fetches all data from projects folder */
    func fetchReviews() {
      Database.database().reference().child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let review = Review(from: dictionary)
                let currentId = self.currentUserId
                if review.about_id == currentId {
                    self.reviews.append(review)
                }
            })
            self.fetchReviewersPhotos()
            /* Manually all the table view to reload itself and to refresh. Otherwise no changes will be seen */
            self.reviewsTableView?.reloadData()
            self.reviewsTableView?.refreshControl?.endRefreshing()
        }) { (error) in
            print("Failed to fetch reviews with error: \(error)")
        }
        self.reviewsTableView.reloadData()
        self.reviewsTableView.refreshControl?.endRefreshing()
    } // end fetchReviews
        
    @objc func handleRefresh() {
        reviews.removeAll()
        fetchReviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "reviewDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewDetailSegue" {
            let dvc = segue.destination as! ReviewViewController
            dvc.stars = reviews[reviewsTableView.selectedIndex].stars
            dvc.reviewWords = reviews[reviewsTableView.selectedIndex].reviewWords
            let currentReview = reviews[reviewsTableView.selectedIndex]
            dvc.reviewerPhotoString = reviewersPhotos[currentReview.user_id]!
            dvc.arrivedAfterProfileSegue = self.didSegueHere
        }
    }
    
    ////////////// Allow user profile photo to be changed //////////////
    @objc func handlePhotoUploadCurrentUser() {
        //check if profile is current user's profile
      if self.currentUserId == Auth.getCurrentUserId()
        {
            self.handlePhotoUpload()
        }
        else
        {
            print("Cannot change profile photo, not current user's profile.")
        }
    }
    
    func handlePhotoUpload() {
        let cameraOrPhotoAlbum = UIAlertController(title: "Change Profile Photo", message: "Photo Source", preferredStyle: .actionSheet)
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let cameraOption = UIAlertAction(title: "Camera", style: .default) { (_) in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        let photoAlbumOption = UIAlertAction(title: "Photo Album", style: .default) { (_) in
            self.present(picker, animated: true, completion: nil)
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction) in print("cancelled") }
        
        cameraOrPhotoAlbum.addActions(actions: cameraOption, photoAlbumOption, cancelOption)
        present(cameraOrPhotoAlbum, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        if let image = selectedImage {
            profilePicture.image = image
          let current_user_id = Auth.getCurrentUserId()
          let storageRef = Storage.storage().reference().child("profilePics").child("\(current_user_id).jpg")
            if let profilePic = self.profilePicture.image, let uploadData = UIImageJPEGRepresentation(profilePic, 0.1) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if let error = error
                    {
                        print(error);
                        return
                    }
                    print("Successfully Update Profile Picture")
                    if let profilePicImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["profilePicture": profilePicImageURL] as [String: AnyObject]
                        self.registerInfoIntoDatabaseWithUID(uid: current_user_id, values: values)
                    }
                }
            }
        }       
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
      let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
        let projectsReference = ref.child("users").child(uid)
        projectsReference.updateChildValues(values) { (err, ref) in
            if(err != nil) {
                print("Error Occured: \(err!)")
                return
            }
        }
    }
}

extension UITableView {
    var selectedIndex: Int {
        return indexPathForSelectedRow?.item ?? 0
    }
}


