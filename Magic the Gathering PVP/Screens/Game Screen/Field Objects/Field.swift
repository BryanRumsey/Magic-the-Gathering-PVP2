//
//  Field.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/15/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import UIKit

class Field{
    
    var field: [Cards] = []
    
    init(){
        
    }
    
    func add(card: Cards){
        field.append(card)
    }
    
    func reset(){
        field = []
    }
}
