//
//  Exile.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Exile{
    
    var exilePile: [Cards]
    var image: String
    
    init(){
        exilePile = []
        image = ""
    }
    
    func search(card: Cards) -> Int?{
        if exilePile.count == 0 {
            return nil
        }
        for i in 0..<exilePile.count{
            if exilePile[i].name == card.name{
                return i
            }
        }
        return nil
    }
    
    func add(card: Cards){
        exilePile.insert(card, at: 0)
        setImage()
    }
    
    func setImage(){
        image = exilePile[0].image
    }
    
    func removeCard(card: Cards){
        let Index: Int = search(card: card) ?? -1
        if Index != -1{
            exilePile.remove(at: Index)
        }
    }
}
