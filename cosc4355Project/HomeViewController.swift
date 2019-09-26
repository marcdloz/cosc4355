//
//  ViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var usernameText: UITextField!
  
  @IBOutlet weak var passwordText: UITextField!
  
  @IBAction func login(_ sender: UIButton) {
    /* Handle Login */
    Auth.auth().signIn(withEmail: usernameText.text!, password: passwordText.text!) { [unowned self] (user, error) in
        if let error = error {
        print("Login Failure: \(error)")
        let alertLoginFailure = UIAlertController(title: "Login Error", message: "Please check your username and password.", preferredStyle: .alert)
        let nonAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertLoginFailure.addAction(nonAction);
        self.present(alertLoginFailure, animated: true, completion: nil)
        return
      }
      print("Successful login with user: \((user?.uid)!)")
      self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    usernameText.delegate = self
    passwordText.delegate = self
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    return true
  }
}

