//
//  GameScene.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 1/31/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameStatusBar: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        gameBoardLayout()
    }
    
    func gameBoardLayout(){
        gameStatusBar = SKSpriteNode(color: UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0), size: CGSize(width: frame.size.width, height: 30.0))
        gameStatusBar.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameStatusBar)
        
        player1()
        player2()
    }
    
    func player1(){
        //let name =
        //let life =
        //let manapool =
        
        let library = SKSpriteNode(imageNamed: "Magic_Card_Back")
        library.size = CGSize(width: 50, height: 100)
        library.position = CGPoint(x: frame.minX + 90, y: frame.minY + 100)
        addChild(library)
        
        let exile = SKSpriteNode(imageNamed: "Lava Axe")
        exile.size = CGSize(width: 50, height: 100)
        exile.position = CGPoint(x: frame.minX + 30, y: frame.minY + 210)
        addChild(exile)
        
        //let discard =
    }
    
    func player2(){
        //let name =
        //let life =
        //let manapool =
        //let library =
        //let exile =
        //let discard =
    }
}
