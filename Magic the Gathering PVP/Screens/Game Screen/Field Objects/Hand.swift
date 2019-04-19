//
//  Hand.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Hand{
    
    var hand: [Cards]
    
    init(){
        hand = []
    }
    
    func add(card: Cards){
        hand.append(card)
    }
    
    func remove(card: Cards) -> Cards?{
        var Index: Int = search(card: card) ?? -1
        if Index != -1{
            return hand.remove(at: Index)
        }
        return nil
    }
    
    func search(card: Cards) -> Int?{
        if hand.count == 0{
            return nil
        }
        for i in 0..<hand.count{
            if hand[i].name == card.name{
                return i
            }
        }
        return nil
    }
    
    func reset(){
        hand = []
    }
}
