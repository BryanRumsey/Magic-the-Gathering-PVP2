//
//  gameOverScene.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 4/18/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    let gameView = GameViewController()
    
    override func didMove(to view: SKView) {
        let titleLabel = SKLabelNode(text: "Game Over")
        titleLabel.fontName = "Chalkboard SE Light"
        titleLabel.fontSize = 60
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(titleLabel)
    }
}
