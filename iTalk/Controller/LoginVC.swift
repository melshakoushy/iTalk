//
//  LoginVC.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/21/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.layer.cornerRadius = 10
        emailTxt.layer.cornerRadius = 10
        loginBtn.layer.cornerRadius = 10
        signUpBtn.layer.cornerRadius = 10
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        guard let email = emailTxt.text,
              let password = passwordTxt.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) {(user, error) in
            if let error = error {
                debugPrint("Error signing in: \(error)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
