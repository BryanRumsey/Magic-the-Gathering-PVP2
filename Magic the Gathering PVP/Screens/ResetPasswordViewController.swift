//
//  ResetPasswordViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 2/4/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var usernameError: UILabel!
    @IBOutlet weak var resetInstructions: UILabel!
    @IBOutlet weak var resetPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetPassword.layer.cornerRadius = 15
        
        addToolBarToKeyboard()
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
        self.userName.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: self.userName.text!) { (error) in
            
            let error1 = "The email address is badly formatted."
            let error2 = "There is no user record corresponding to this identifier. The user may have been deleted."
            let instructions = "Follow the instructions that were sent to your email to reset your password!"
            
            if((self.userName.text?.isEmpty)! || error?.localizedDescription == error1){
                self.usernameError.text = "Sorry, you need to enter your email!"
                return
            }else if(error?.localizedDescription == error2){
                self.usernameError.text = "Sorry, that account doesn't exist!"
                return
            }else{
                self.resetInstructions.text = instructions
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                    self.performSegue(withIdentifier: "resetPassword", sender: self)
                })
            }
        }
    }
}
