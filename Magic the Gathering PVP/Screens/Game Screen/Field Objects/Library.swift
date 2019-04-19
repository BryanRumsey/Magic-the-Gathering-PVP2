//
//  Library.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/10/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Library{
    
    var library: [Cards]
    
    init(){
        library = []
    }
    
    func add(card: Cards){
        library.append(card)
    }
    
    func search(card: Cards) -> Int?{
        if library.count == 0{
            return nil
        }
        for i in 0..<library.count{
            if library[i].name == card.name{
                return i
            }
        }
        return nil
    }
    
    func remove(card: Cards) -> Cards?{
        let Index: Int = search(card: card) ?? -1
        if Index != -1{
            return library.remove(at: Index)
        }
        return nil
    }
    
    func draw() -> Cards?{
        if library.count == 0{
            return nil
        }
        return library.remove(at: 0)
    }
    
    func reset(){
        library = []
    }
}
