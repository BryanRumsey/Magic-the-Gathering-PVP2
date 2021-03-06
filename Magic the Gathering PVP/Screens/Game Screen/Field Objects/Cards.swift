//
//  Cards.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/9/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Cards{
    
    var name: String
    var image: String
    var playType: String
    var castType: String
    var cardType: String
    var atk: Int?
    var def: Int?
    var legendary: Bool
    var color: String
    var attributes: [String]
    var subTypes: [String]
    var loyaltyCoiunters: Int?
    var cost: Int
    
    var summoningSickness: Bool = true
    var tapped: Bool = false
    var attacking: Bool = false
    var blocked: Bool = false
    var damage: Int = 0
    
    init(name: String, image: String, playType: String, castType: String, cardType: String, atk: Int, def: Int, legendary: Bool, color: String, attributes: [String], subTypes: [String], loyaltyCoiunters: Int, cost: Int){
        self.name = name
        self.image = image
        self.playType = playType
        self.castType = castType
        self.cardType = cardType
        self.atk = atk
        self.def = def
        self.legendary = legendary
        self.color = color
        self.attributes = attributes
        self.subTypes = subTypes
        self.loyaltyCoiunters = loyaltyCoiunters
        self.cost = cost
        for attribute in attributes{
            if attribute == "Haste"{
                summoningSickness = false
            }
        }
    }
    
    func tap(){
        self.tapped = true
    }
    
    func untap(){
        self.tapped = false
    }
    
    
}
