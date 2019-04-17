//
//  GameViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 1/31/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase
import SpriteKit

class GameViewController: UIViewController {

    var scene: SKScene!
    
    var ref: DatabaseReference!
    var postHandle: DatabaseHandle!
    var userID: String = ""

    @IBOutlet weak var background: UIImageView!
    
    //Player 1
    @IBOutlet weak var p1NameLabel: UILabel!
    @IBOutlet weak var p1LifeLabel: UILabel!
    static var p1LibraryName: String = ""
    
    //Player 2
    @IBOutlet weak var p2NameLabel: UILabel!
    @IBOutlet weak var p2LifeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getLibraryName()
    }
    
    func getLibraryName(){
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        var libraryNames: [String] = []
        let nameCRef = ref.child("users/\(userID)/collection")
        let postHandle1 = nameCRef.observe(DataEventType.childAdded, with: { (snapshot) in
            if snapshot.key != "libraryLimit" || snapshot.key != "Card Box"{
                libraryNames.append(snapshot.key)
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.selectLibrary(libraryNames: libraryNames)
        }
    }
    
    func selectLibrary(libraryNames: [String]){
        let alert = UIAlertController(title: "Please enter the name of your library", message: "You can name the library what ever you would like.  If you don't name your library you won't be able to create it.", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your library name"
        }
        let action = UIAlertAction(title: "Name Library", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            GameViewController.p1LibraryName = textField.text!
            self.loadScene()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
                self.background.alpha = 0.0
            }
        }
        action.isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let textField = alert.textFields![0] as UITextField
            for i in 0..<libraryNames.count{
                if libraryNames[i] == textField.text! {
                    action.isEnabled = !textField.text!.isEmpty
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
            self.performSegue(withIdentifier: "endMatch", sender: self)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
    }

    func loadScene(){
        if let view = self.view as! SKView? {
            scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
