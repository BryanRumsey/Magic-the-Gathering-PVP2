//
//  Discard.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Discard{
    
    var discardPile: [Cards]
    var image: String
    
    init() {
        discardPile = []
        image = ""
    }
    
    func add(card: Cards){
        discardPile.insert(card, at: 0)
        setImage()
    }
    
    func remove(card: Cards) -> Cards?{
        var Index: Int = search(card: card) ?? -1
        if Index != -1{
            return discardPile.remove(at: Index)
        }
        return nil
    }
    
    func search(card: Cards) -> Int?{
        if discardPile.count == 0{
            return nil
        }
        for i in 0..<discardPile.count{
            if discardPile[i].name == card.name{
                return i
            }
        }
        return nil
    }
    
    func setImage(){
        image = discardPile[0].image
    }
    
    func reset(){
        discardPile = []
    }
}
