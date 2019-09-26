//
//  ProjectFormViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ProjectFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
  
  @IBOutlet weak var uploadImage: UIImageView!
  
  @IBOutlet weak var titleInput: UITextField!
  
  
  @IBOutlet weak var descriptionInput: UITextView!
  
  @IBOutlet weak var bidDesiredInput: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
    view.addGestureRecognizer(tap)
    
    /* Tap gesture utilized when the user taps on the UIImageView above the post button. */
    uploadImage.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUpload))
    self.uploadImage.addGestureRecognizer(tapGesture)
    
    titleInput.delegate = self
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    currentLat = locationManager.location?.coordinate.latitude.description ?? "0"
    currentLong = locationManager.location?.coordinate.longitude.description ?? "0"
    print("\(currentLong) \(currentLat)")
  }
  
  @objc func dismissKb() {
    view.endEditing(true)
  }
  
  var currentLat = "0"
  var currentLong = "0"
  let locationManager = CLLocationManager()
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    return true
  }
  
  /* Sets the selected imaged based on whether it was edited or not */
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImage = originalImage
    }
    if let image = selectedImage {
      uploadImage.image = image
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  /* Sets up a choice between camera roll or using the camera itself. Keep note that the simulator does NOT have a camera. */
  @objc func handlePhotoUpload() {
    let cameraOrPhotoAlbum = UIAlertController(title: "Source", message: "Photo Source", preferredStyle: .actionSheet)
    
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
  
  
  @IBAction func postButton(_ sender: UIButton) {
    guard let title = titleInput.text, let description = descriptionInput.text, let bidDesired = bidDesiredInput.text else { return }
    if !validateFields(fields: title, description, bidDesired) { return }
    
    let imageName = NSUUID().uuidString
    let storageRef = Storage.storage().reference().child("projects").child("\(imageName).jpg")
    
    if let projectImage = uploadImage.image, let uploadData = UIImageJPEGRepresentation(projectImage, 0.1) {
      storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
        if let error = error { print(error); return }
        
        /* Set up date */
        let currentDate = Date.currentDate
        
        /* Get current user id */
        guard let uid = Auth.auth().currentUser?.uid else { print("Error: User not signed in"); return }
 
        /* Generate projectId, get values, then store into database */
        if let projectImageUrl = metadata?.downloadURL()?.absoluteString {
          let projectId = UUID().uuidString
          let values = ["title": title, "description": description, "status": String(describing: Status.pending), "category": "", "date": currentDate, "photoUrl": projectImageUrl, "startingBid": bidDesired, "acceptedBid": "0", "latitude": self.currentLat, "longitude": self.currentLong, "location": Address().toString(), "posting_id": projectId, "user_id": uid]
          self.registerInfoIntoDatabaseWithUID(uid: projectId, values: values as [String: AnyObject])
          self.navigationController?.popViewController(animated: true)
        }
      }
    }
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = Database.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("projects").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  /* Makes sure every field is not blank. */
  private func validateFields(fields: String...) -> Bool {
    for field in fields {
      if field == "" {
        return false
      }
    }
    return true
  }
}
