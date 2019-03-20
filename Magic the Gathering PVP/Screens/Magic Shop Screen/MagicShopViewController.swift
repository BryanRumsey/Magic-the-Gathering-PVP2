//
//  MagicShopViewController.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 3/19/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit
import Firebase

class magicShopViewController: UIViewController {
    
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var numberOfCoins: UILabel!
    @IBOutlet weak var shopItemCollectionView: UICollectionView!
    
    var coins: Int = 0 {
        didSet {
            numberOfCoins.text = "\(coins)"
        }
    }
    var libraryLimit: Int = 0
    var cardBoxLimit: Int = 0
    
    var images: [String] = [] {
        didSet {
            shopItemCollectionView.reloadData()
        }
    }
    var descriptions: [String] = []
    var costs: [Int] = [] {
        didSet {
            shopItemCollectionView.reloadData()
        }
    }
    var names: [String] = [] {
        didSet {
            shopItemCollectionView.reloadData()
        }
    }
    
    var ref: DatabaseReference!
    var postHandle: DatabaseHandle!
    let userID = (Auth.auth().currentUser?.uid)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        if let flowLayout = shopItemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout, let collectionView = shopItemCollectionView {
            let width = view.frame.width / 2 - 5
            flowLayout.estimatedItemSize = CGSize(width: width, height: 200)
        }
        
        coinImage.layer.cornerRadius = 15
        getUsersCoins()
        getLibraryLimit()
        getCardBoxLimit()
        
        shopItemCollectionView.delegate = self
        shopItemCollectionView.dataSource = self
        
        getShopItems()
    }
    
    func getUsersCoins(){
        let coinsRef = ref.child("users/\(self.userID)/coins")
        coinsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.coins = snapshot.value as! Int
        })
    }
    
    func getLibraryLimit(){
        let libLimRef = ref.child("users/\(self.userID)/libraryLimit")
        libLimRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.libraryLimit = snapshot.value as! Int
        })
    }
    
    func getCardBoxLimit(){
        let cbLimRef = ref.child("users/\(self.userID)/cardBoxLimit")
        cbLimRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.cardBoxLimit = snapshot.value as! Int
        })
    }
    
    func getShopItems() {
        let itemRef = ref.child("shop")
        if postHandle != nil {
            itemRef.removeObserver(withHandle: self.postHandle)
        }
        postHandle = itemRef.observe(.childAdded, with: { (snapshot) in
            self.getItemName(nameRef: itemRef.child("\(snapshot.key)/name"))
            self.getItemImage(imgRef: itemRef.child("\(snapshot.key)/image"))
            self.getItemCost(costRef: itemRef.child("\(snapshot.key)/cost"))
            self.getItemDescription(desRef: itemRef.child("\(snapshot.key)/description"))
        })
    }
    
    func getItemName(nameRef: DatabaseReference){
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.names.append(snapshot.value as! String)
        })
    }
    
    func getItemCost(costRef: DatabaseReference){
        costRef.observeSingleEvent(of: .value) { (snapshot) in
            self.costs.append(snapshot.value as! Int)
        }
    }
    
    func getItemImage(imgRef: DatabaseReference){
        imgRef.observeSingleEvent(of: .value) { (snapshot) in
            self.images.append(snapshot.value as! String)
        }
    }
    
    func getItemDescription(desRef: DatabaseReference){
        desRef.observeSingleEvent(of: .value) { (snapshot) in
            self.descriptions.append(snapshot.value as! String)
        }
    }
}

extension magicShopViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ShopItems
        itemCell?.setItemDetails(image: UIImage(named: images[indexPath.row])!, name: names[indexPath.row], cost: "\(costs[indexPath.row])")
        return itemCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if coins < costs[indexPath.row] {
            let alert = UIAlertController(title: "Insufficient Coins", message: "You don't have enough coins to make this purchase.", preferredStyle: UIAlertController.Style.alert)
            let cancel = UIAlertAction(title: "Close", style: .default) { (alertAction) in }
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else if names[indexPath.row] == "Additional Library" {
            let alert = UIAlertController(title: names[indexPath.row], message: descriptions[indexPath.row], preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Purchase", style: .default) { (alertAction) in
                self.coins = self.coins - self.costs[indexPath.row]
                self.libraryLimit = self.libraryLimit + 1
                let userRef = self.ref.child("users/\(self.userID)")
                userRef.child("coins").setValue(self.coins)
                userRef.child("libraryLimit").setValue(self.libraryLimit)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else if names[indexPath.row] == "Card Box Expansion" {
            let alert = UIAlertController(title: names[indexPath.row], message: descriptions[indexPath.row], preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Purchase", style: .default) { (alertAction) in
                self.coins = self.coins - self.costs[indexPath.row]
                self.cardBoxLimit = self.cardBoxLimit + 10
                let userRef = self.ref.child("users/\(self.userID)")
                userRef.child("coins").setValue(self.coins)
                userRef.child("cardBoxLimit").setValue(self.cardBoxLimit)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
