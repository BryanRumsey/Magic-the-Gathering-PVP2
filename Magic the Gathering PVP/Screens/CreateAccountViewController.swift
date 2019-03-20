//
//  CreateAccountViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 2/4/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameError: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.layer.cornerRadius = 15
        
        addToolBarToKeyboard()
        
        ref = Database.database().reference()
    }
    
    func addToolBarToKeyboard(){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LoginViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.firstName.inputAccessoryView = toolbar
        self.lastName.inputAccessoryView = toolbar
        self.username.inputAccessoryView = toolbar
        self.password.inputAccessoryView = toolbar
        self.password2.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        let error1 = "The email address is badly formatted."
        
        if password.text != password2.text {
            usernameError.text = ""
            passwordError.text = "Sorry, the passwords you entered didn't match!"
        } else if(password.text?.count ?? 0 < 8) {
            usernameError.text = ""
            passwordError.text = "Sorry, the password must be at least 8 characters!"
        } else {
            Auth.auth().createUser(withEmail: username.text!, password: password.text!) { (authResult, error) in
                if(error1 == error?.localizedDescription || (self.username.text?.isEmpty)!){
                    self.usernameError.text = "Sorry, you must enter an email!"
                    self.passwordError.text = ""
                    return
                }
                guard let _ = authResult?.user.email, error == nil else {
                    self.usernameError.text = "Sorry, that username is already in use!"
                    self.passwordError.text = ""
                    return
                }
                
                guard let user = authResult?.user else { return }
                
                self.ref.child("users").child(user.uid).setValue(["firstName":self.firstName.text, "lastName":self.lastName.text, "email":self.username.text])
                self.ref.child("users/\(user.uid)").child("role").setValue("user")
                self.ref.child("users/\(user.uid)").child("coins").setValue("120")
                self.ref.child("users/\(user.uid)").child("cardBoxLimit").setValue("60")
                self.ref.child("users/\(user.uid)").child("collection").child("Card Box").setValue(["cover":"cardBoxCover", "cards":"empty"])
                self.performSegue(withIdentifier: "createAccount", sender: self)
            }
        }
    }
}
