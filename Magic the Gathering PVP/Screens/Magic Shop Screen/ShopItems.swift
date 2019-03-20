//
//  ShopItems.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 3/19/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class ShopItems: UICollectionViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    
    func setItemDetails(image: UIImage, name: String, cost: String){
        coinImage.layer.cornerRadius = 10
        itemImage.image = image
        itemDescription.text = name
        itemCost.text = cost
    }
}
