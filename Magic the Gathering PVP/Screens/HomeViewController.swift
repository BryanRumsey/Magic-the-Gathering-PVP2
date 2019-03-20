//
//  HomeViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 2/4/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var usersName: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var numberOfCoins: UILabel!
    @IBOutlet weak var collectionsButton: UIButton!
    @IBOutlet weak var challengePlayerButton: UIButton!
    @IBOutlet weak var chatRoomButton: UIButton!
    @IBOutlet weak var magicShopButton: UIButton!
    @IBOutlet weak var tutorialsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let userID = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    
    var usersFullName: String = "" {
        didSet {
            usersName.text = usersFullName
        }
    }
    var firstName: String = "" {
        didSet {
            getUsersLastName()
        }
    }
    var lastName: String = "" {
        didSet {
            usersFullName = firstName + " " + lastName
        }
    }
    var coins: Int = 0 {
        didSet {
            numberOfCoins.text = "\(coins)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionsButton.layer.cornerRadius = 20
        challengePlayerButton.layer.cornerRadius = 20
        chatRoomButton.layer.cornerRadius = 20
        magicShopButton.layer.cornerRadius = 20
        tutorialsButton.layer.cornerRadius = 20
        logoutButton.layer.cornerRadius = 15
        
        coinImage.layer.cornerRadius = 15
        
        ref = Database.database().reference()
        
        getUsersFirstName()
        getUsersCoins()
    }
    
    func getUsersFirstName() {
        let firstNRef = ref.child("users/\(self.userID!)/firstName")
        firstNRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.firstName = snapshot.value as! String
        })
    }
    
    func getUsersLastName() {
        let lastNRef = ref.child("users/\(self.userID!)/lastName")
        lastNRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.lastName = snapshot.value as! String
        })
    }
    
    func getUsersCoins(){
        let lastNRef = ref.child("users/\(self.userID!)/coins")
        lastNRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.coins = snapshot.value as! Int
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        var user = Auth.auth().currentUser
        print(user!.email!)
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        user = Auth.auth().currentUser
        if(user == nil){
            print("signed out")
        }
        performSegue(withIdentifier: "logout", sender: self)
    }
    
}
