//
//  CardCollectionViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 2/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase

class CardCollectionViewController: UIViewController {
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var cardLibraryView: UICollectionView!
    @IBOutlet weak var editLibraryButton: UIButton!
    @IBOutlet weak var deleteLibraryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var collectionName: UILabel!
    
    var ref: DatabaseReference!
    var userID: String = ""
    
    var displayArray1: [String] = [] {
        didSet {
            self.cardCollectionView.reloadData()
        }
    }
    var collectionNamesArray: [String] = []
    var collectionIndex: Int = 0
    
    var displayArray2: [String] = [] {
        didSet {
            self.cardLibraryView.reloadData()
        }
    }
    var cardKeysArray: [String] = []
    var cardNamesArray: [String] = []
    
    var cardBoxLimit: Int = 0
    var cardBoxCount: Int = 0
    var libraryLimit: Int = 0
    
    var postHandle1: DatabaseHandle!
    var postHandle2: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editLibraryButton.layer.cornerRadius = 15
        deleteLibraryButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 5
        
        cardCollectionView.backgroundView = UIImageView(image: UIImage(named: "background.png"))
        cardLibraryView.backgroundView = UIImageView(image: UIImage(named: "background.png"))
        
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        displayCollections()
        
        getCardBoxLimit()
        getCardBoxCount()
        getLibraryLimit()
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        cardLibraryView.delegate = self
        cardLibraryView.dataSource = self
    }
    
    func displayCollections() {
        getCollectionNames()
    }
    
    func getCollectionNames() {
        let nameCRef = ref.child("users/\(userID)/collection")
        if postHandle1 != nil {
            nameCRef.removeObserver(withHandle: self.postHandle1)
        }
        postHandle1 = nameCRef.observe(DataEventType.childAdded, with: { (snapshot) in
            if snapshot.key != "libraryLimit" {
                self.collectionNamesArray.append(snapshot.key)
                self.getCollectionCoverImage(name: snapshot.key)
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.displayArray1.append("add")
            self.collectionNamesArray.append("addLibrary")
        }
    }
    
    func getCollectionCoverImage(name: String){
        let coverCRef = ref.child("users/\(userID)/collection/\(name)/cover")
        coverCRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? String ?? nil
            if data != nil{
                self.displayArray1.append(snapshot.value as! String)
            }
        })
    }
    
    func getCardBoxLimit(){
        let cblRef = ref.child("users/\(userID)/collection/Card Box/cardBoxLimit")
        cblRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.cardBoxLimit = snapshot.value as! Int
        })
    }
    
    func getCardBoxCount(){
        let cbcRef = ref.child("users/\(userID)/collection/Card Box/cardBoxCount")
        cbcRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.cardBoxCount = snapshot.value as! Int
        })
    }
    
    func getLibraryLimit() {
        let llRef = ref.child("users/\(userID)/collection/libraryLimit")
        llRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.libraryLimit = snapshot.value as! Int
        })
    }
    
    func displayCollection(collectionName: String){
        displayArray2.removeAll()
        cardKeysArray.removeAll()
        cardNamesArray.removeAll()
        self.getCollectionCardKeys(collectionName: collectionName)
    }
    
    func getCollectionCardKeys(collectionName: String){
        let nameCRef = ref.child("users/\(userID)/collection/\(collectionName)/cards")
        if postHandle2 != nil {
            nameCRef.removeObserver(withHandle: self.postHandle2)
        }
        postHandle2 = nameCRef.observe(DataEventType.childAdded, with: { (snapshot) in
            self.cardKeysArray.append(snapshot.key)
            self.getCollectionCardImage(collectionName: collectionName, cardKey: snapshot.key)
            self.getCollectionCardNames(collectionName: collectionName, cardKey: snapshot.key)
        })
    }
    
    func getCollectionCardImage(collectionName: String, cardKey: String){
        let imgCBRef = ref.child("users/\(userID)/collection/\(collectionName)/cards/\(cardKey)/image")
        imgCBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.displayArray2.append(snapshot.value as! String)
        })
    }
    
    func getCollectionCardNames(collectionName: String, cardKey: String){
        let nameLRef = ref.child("users/\(userID)/collection/\(collectionName)/cards/\(cardKey)/name")
        nameLRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let cardName = snapshot.value as! String
            self.cardNamesArray.append(cardName)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createLibrary" {
            if let destination = segue.destination as? buildLibraryViewController {
                destination.name = collectionName.text!
            }
        }
    }
    
    func setCollectionName(index: Int){
        self.collectionName.text = collectionNamesArray[index]
        self.collectionName.textColor = UIColor.init(displayP3Red: 255, green: 255, blue: 255, alpha: 0.75)
        self.collectionName.textAlignment = NSTextAlignment.center
        self.collectionName.font = UIFont(name: "Chalkboard SE", size: 30)
        self.displayCollection(collectionName: collectionNamesArray[index])
        testButtons()
    }
    
    func testButtons(){
        if collectionName.text == "" || collectionName.text == "Card Box" {
            editLibraryButton.isEnabled = false
            editLibraryButton.isHidden = true
            deleteLibraryButton.isEnabled = false
            deleteLibraryButton.isHidden = true
        } else {
            editLibraryButton.isEnabled = true
            editLibraryButton.isHidden = false
            deleteLibraryButton.isEnabled = true
            deleteLibraryButton.isHidden = false
        }
    }
    @IBAction func editLibraryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "createLibrary", sender: self)
    }
    
    @IBAction func deleteLibraryButtonTapped(_ sender: Any) {
        for i in 0..<cardNamesArray.count{
            if cardNamesArray[i] != "Forest" && cardNamesArray[i] != "Island" && cardNamesArray[i] != "Mountain" && cardNamesArray[i] != "Plains" && cardNamesArray[i] != "Swamp"{
                let dataLRef = ref.child("users/\(userID)/collection/\(self.collectionName.text!)/cards/\(self.cardKeysArray[i])")
                dataLRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    self.ref.child("users/\(self.userID)/collection/Card Box/cards/").updateChildValues([snapshot.key:snapshot.value!])
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.ref.child("users/\(self.userID)/collection/\(self.collectionName.text!)").removeValue()
            self.collectionNamesArray.remove(at: self.collectionIndex)
            self.displayArray1.remove(at: self.collectionIndex)
            self.displayArray2.removeAll()
            self.collectionName.text = ""
            self.testButtons()
        }
    }
    
    func addCardToCardBox(){
        let alert = UIAlertController(title: "Add a Card to Your Card Box", message: "Please enter the name of the card you wish to add.", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the card name"
        }
        let action = UIAlertAction(title: "Add Card", style: .default) { (alertAction) in
            self.getCardData(name: alert.textFields![0].text!)
            alert.dismiss(animated: true)
        }
        action.isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let textField = alert.textFields![0] as UITextField
            action.isEnabled = !textField.text!.isEmpty
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
    }
    
    func getCardData(name: String){
        let dataRef = ref.child("cards/\(name)")
        let cardBoxRef = ref.child("users/\(userID)/collection/Card Box/cards")
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() && (name != "basicLands" || name != "tokens"){
                cardBoxRef.childByAutoId().setValue(snapshot.value)
                self.cardBoxCount = self.cardBoxCount + 1
                self.ref.child("users/\(self.userID)/collection/Card Box/cardBoxCount").setValue(self.cardBoxCount)
                let data = snapshot.value! as Any
                print(data)
            } else {
                let alert = UIAlertController(title: "Card Not Found", message: "\(name) is not currently available.  If you would like to send a request to have the card added tap 'Yes'", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "Yes", style: .default) { (alertAction) in
                    self.ref.child("requests").updateChildValues([name:"Can \(name) be added to the list of available cards?"])
                }
                let cancel = UIAlertAction(title: "No", style: .default) { (alertAction) in }
                alert.addAction(action)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func deleteCardBoxCard(index: Int){
        self.ref.child("users/\(self.userID)/collection/Card Box/cards/\(self.cardKeysArray[index])").removeValue()
        self.cardKeysArray.remove(at: index)
        self.cardNamesArray.remove(at: index)
        self.displayArray2.remove(at: index)
        self.cardBoxCount = self.cardBoxCount - 1
        self.ref.child("users/\(self.userID)/collection/Card Box/cardBoxCount").setValue(self.cardBoxCount)
        if(self.cardBoxCount == 0) {
            self.ref.child("users/\(self.userID)/collection/Card Box").child("cards").setValue("empty")
        }
    }
}

extension CardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.cardCollectionView){
            return displayArray1.count
        }else{
            return displayArray2.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.cardCollectionView){
            let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardBoxCell", for: indexPath) as? CardCollection
            cardCell?.cardImg.image = UIImage(named: displayArray1[indexPath.row])
            return cardCell!
        }else{
            let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardLibraryCell", for: indexPath) as? CardLibrary
            cardCell?.cardImg.image = UIImage(named: displayArray2[indexPath.row])
            return cardCell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.cardCollectionView){
            if collectionNamesArray[indexPath.row] != "addLibrary" {
                self.setCollectionName(index: indexPath.row)
                self.collectionIndex = indexPath.row
                if collectionNamesArray[indexPath.row] == "Card Box" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.displayArray2.append("add")
                        self.cardKeysArray.append("addCard")
                        self.cardNamesArray.append("addCard")
                    }
                }
            }else if (displayArray1.count - 2 < libraryLimit){
                self.collectionName.text = ""
                self.performSegue(withIdentifier: "createLibrary", sender: self)
            } else {
                let alert = UIAlertController(title: "Library Limit Reached", message: "You have reached the maximum number of Libraries that you can build.  If you wish to build another Library you can delete a Library or you may purchase an additional Library from the Magic Shop.", preferredStyle: UIAlertController.Style.alert)
                let cancel = UIAlertAction(title: "Close", style: .default) { (alertAction) in }
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            if cardNamesArray[indexPath.row] == "addCard"{
                if cardBoxCount < cardBoxLimit {
                    addCardToCardBox()
                } else {
                    let alert = UIAlertController(title: "Card Box Limit Reached", message: "You have reached the maximum number of cards that your Card Box can hold.  If you wish to add another card you can remove cards from your Card Box or you may purchase a Card Box Expansion from the Magic Shop.", preferredStyle: UIAlertController.Style.alert)
                    let cancel = UIAlertAction(title: "Close", style: .default) { (alertAction) in }
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
            } else if(self.collectionName.text == "Card Box") {
                let alert = UIAlertController(title: "Remove Card", message: "Are you sure you would like to remove this card?", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "Remove", style: .default) { (alertAction) in
                    self.deleteCardBoxCard(index: indexPath.row)
                }
                let cancel = UIAlertAction(title: "cancel", style: .default) { (alertAction) in }
                alert.addAction(action)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
