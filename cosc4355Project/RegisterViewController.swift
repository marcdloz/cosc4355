//
//  RegisterViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

/**
 *  HEAVY CODE DUPLICATION IN THIS CLASS WITH ProjectFormViewController
 *  Must refactor.
 */


class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var clientOrContractor: UISegmentedControl!
  
  @IBOutlet weak var profilePicture: UIImageView!
  
  @IBOutlet weak var emailText: UITextField!
  
  @IBOutlet weak var passwordText: UITextField!
  
  @IBOutlet weak var confirmPasswordText: UITextField!
  
  @IBOutlet weak var nameText: UITextField!
  
  /* Handle registration */
  @IBAction func register(_ sender: UIButton) {
    if !isFieldsValid() { return }
    
    /* Standard user registration */
    
    Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
      if let error = error {
        print("Error creating new user: \(error)")
        return
      }
      print("Created user: \(String(describing: user?.uid))")
      guard let uid = user?.uid else { return }
      
      /* STORE USER PROFILE */
      let storageRef = Storage.storage().reference().child("profilePics").child("\(uid).jpg")
      if let profilePic = self.profilePicture.image, let uploadData = UIImageJPEGRepresentation(profilePic, 0.1) {
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
          if let error = error { print(error); return }
          print("Succesful Photo Upload")
          if let projectImageUrl = metadata?.downloadURL()?.absoluteString {
            let values = ["name": self.nameText.text!, "profilePicture": projectImageUrl, "email": user?.email!, "userType": self.clientOrContractor.getSelectedTitle()] as [String: AnyObject]
            self.registerInfoIntoDatabaseWithUID(uid: uid, values: values)
          }
        }
      }
    
      self.emailText.text = ""
      self.passwordText.text = ""
      self.confirmPasswordText.text = ""
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  /** Slide keyboard - start */
  var activeTextField: UITextField!
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    activeTextField = textField
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  @objc func keyboardDidShow(notification:Notification){
    let info:NSDictionary = notification.userInfo! as NSDictionary
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    let keyboardY = self.view.frame.size.height - keyboardSize.height
    
    let editingTextFieldY:CGFloat! = self.activeTextField?.frame.origin.y
    
    if self.view.frame.origin.y >= 0 {
      //Checking if the textfield is really hidden behind the keyboard
      if editingTextFieldY > keyboardY - 60 {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
          self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 60)), width: self.view.bounds.width,height: self.view.bounds.height)
        }, completion: nil)
      }
    }
    
  }
  
  
  @objc func keyboardWillHide(notification:Notification){
    UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
      self.view.frame = CGRect(x: 0, y: 0,width: self.view.bounds.width, height: self.view.bounds.height)
    }, completion: nil)
    
  }

 /* Slide keyboard - end */
  
  
  
  @IBAction func goBackButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  func isFieldsValid() -> Bool {
    if emailText.text! == "" || passwordText.text! == "" || confirmPasswordText.text! == "" || nameText.text! == "" {
      print("Error: Empty field indicated")
        let alertEmptyFields = UIAlertController(title: "Not Registered", message: "There are empty fields.", preferredStyle: .alert)
        let nonAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertEmptyFields.addAction(nonAction);
        self.present(alertEmptyFields, animated: true, completion: nil)
      return false
    }
    
    let clearAction = UIAlertAction(title: "Okay", style: .default, handler: { action in
        self.passwordText.text = ""
        self.confirmPasswordText.text = ""
    })
    
    if passwordText.text! != confirmPasswordText.text! {
      print("Error: Passwords does not match")
      let alertPasswordsDoNotMatch = UIAlertController(title: "Not Registered", message: "Passwords do not match.", preferredStyle: .alert)
        alertPasswordsDoNotMatch.addAction(clearAction);
        self.present(alertPasswordsDoNotMatch, animated: true, completion: nil)
      return false
    }
    
    if passwordText.text!.characters.count < 6 {
        print("Error: Passwords must be 6 characters long or more.")
        let alertShortPassword = UIAlertController(title: "Not Registered", message: "Password must be at least 6 characters long.", preferredStyle: .alert)
        alertShortPassword.addAction(clearAction);
        self.present(alertShortPassword, animated: true, completion: nil)
        return false
    }
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
    profilePicture.layer.masksToBounds = true
    // Do any additional setup after loading the view.
    
    profilePicture.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUpload))
    profilePicture.addGestureRecognizer(tapGesture)
    
    emailText.delegate = self
    passwordText.delegate = self
    confirmPasswordText.delegate = self
    nameText.delegate = self
    
    /* Slide keyboard */
    let center: NotificationCenter = NotificationCenter.default;
    center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    center.addObserver(self, selector:#selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    textField.resignFirstResponder()
    return true
  }
  
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
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImage = originalImage
    }
    if let image = selectedImage {
      profilePicture.image = image
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
