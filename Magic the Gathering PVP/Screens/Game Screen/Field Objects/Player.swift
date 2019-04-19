//
//  Player.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Player{
    
    var library: Library = Library()
    var hand: Hand = Hand()
    var discardPile: Discard = Discard()
    var exilePile: Exile = Exile()
    var field: Field = Field()
    var life: Int = 20
    var name: String
    var activePlayer: Bool = false
    var playedLand: Bool = false
    
    init(name: String){
        self.name = name
    }
    
    func reduceLife(amount: Int) -> Int{
        life -= amount
        return life
    }
    
    func addLife(amount: Int) -> Int{
        life += amount
        return life
    }
    
    func shuffleLibrary(){
        print("shuffling library")
        for _ in 0..<library.library.count*7{
            let card = library.library.remove(at: Int.random(in: 0..<library.library.count))
            library.library.insert(card, at: Int.random(in: 0..<library.library.count))
        }
    }
    
    func drawCard(){
        let card = library.draw()
        hand.add(card: card!)
    }
    
    func playCard(card: Cards){
        let card = hand.remove(card: card)
        field.add(card: card!)
    }
    
    func discardCard(card: Cards){
        let card = hand.remove(card: card)
        discardPile.add(card: card!)
    }
    
    func reset(){
        library.reset()
        hand.reset()
        discardPile.reset()
        exilePile.reset()
        field.reset()
    }
}
