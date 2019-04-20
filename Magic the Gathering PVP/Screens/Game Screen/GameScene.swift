//
//  GameScene.swift
//  Magic the Gathering PVP
//
//  Created by Bryan Rumsey on 1/31/19.
//  Copyright © 2019 Bryan Rumsey. All rights reserved.
//

import SpriteKit
import Firebase

@objcMembers
class MainGameScene: SKScene {
    
    let gameView = GameViewController()
    
    let sceneXBuffer: Int = 20
    let sceneYBuffer: Int = 40
    let elementWidth: Int = 45
    let elementHeight: Int = (45/3)*5
    
    var ref: DatabaseReference!
    var postHandle: DatabaseHandle!
    var userID: String = ""
    
    var player1: Player = Player(name: "Bryan")
    var p1LibraryName: String = ""{
        didSet{
            setUpField()
        }
    }
    let p1NameLabel = SKLabelNode(text: "Player 1")
    let p1LifeLabel = SKLabelNode(text: "20")
    var p1Life: Int = 20 {
        didSet{
            player1.life = p1Life
            p1LifeLabel.text = "\(p1Life)"
        }
    }
    var p1GameItems: [SKSpriteNode] = []
    var p1Target: Int = -1
    var p1LandX: Int = 0
    var p1LandY: Int = 0
    var p1NonLandX: Int = 0
    var p1ManaPool: Int = 0
    
    var player2: Player = Player(name: "Oliver")
    let p2NameLabel = SKLabelNode(text: "Player 2")
    let p2LifeLabel = SKLabelNode(text: "20")
    var p2Life: Int = 20 {
        didSet{
            player2.life = p2Life
            p2LifeLabel.text = "\(p2Life)"
        }
    }
    var p2GameItems: [SKSpriteNode] = []
    var p2Target: Int = -1
    var p2LandX: Int = 0
    var p2LandY: Int = 0
    var p2NonLandX: Int = 0
    var p2ManaPool: Int = 0
    
    //Card variables
    var i = 0, j = 0
    var p1cardName: [String] = []
    var p1image: [String] = []
    var p1playType: [String] = []
    var p1cardType: [String] = []
    var p1castType: [String] = []
    var p1atk: [Int] = []
    var p1def: [Int] = []
    var p1legendary: [Bool] = []
    var p1color: [String] = []
    var p1attributes: [[String]] = []
    var p1subTypes: [[String]] = []
    var p1LoyaltyCounters: [Int] = []{
        didSet{
            let card = Cards(name: self.p1cardName[i], image: self.p1image[i], playType: self.p1playType[i], castType: self.p1castType[i], cardType: self.p1cardType[i], atk: self.p1atk[i], def: self.p1def[i], legendary: self.p1legendary[i], color: self.p1color[i], attributes: self.p1attributes[i], subTypes: self.p1subTypes[i], loyaltyCoiunters: self.p1LoyaltyCounters[i], cost: self.p1Cost[i])
            player1.library.add(card: card)
            self.i += 1
        }
    }
    var p1Cost: [Int] = []
    
    var p2cardName: [String] = []
    var p2image: [String] = []
    var p2playType: [String] = []
    var p2cardType: [String] = []
    var p2castType: [String] = []
    var p2atk: [Int] = []
    var p2def: [Int] = []
    var p2legendary: [Bool] = []
    var p2color: [String] = []
    var p2attributes: [[String]] = []
    var p2subTypes: [[String]] = []
    var p2LoyaltyCounters: [Int] = []{
        didSet{
            let card = Cards(name: self.p2cardName[j], image: self.p2image[j], playType: self.p2playType[j], castType: self.p2castType[j], cardType: self.p2cardType[j], atk: self.p2atk[j], def: self.p2def[j], legendary: self.p2legendary[j], color: self.p2color[j], attributes: self.p2attributes[j], subTypes: self.p2subTypes[j], loyaltyCoiunters: self.p2LoyaltyCounters[j], cost: self.p2Cost[j])
            player2.library.add(card: card)
            self.j += 1
        }
    }
    var p2Cost: [Int] = []
    
    var gamePhases: [String] = ["Untap Phase", "Draw Phase", "Main Phase One", "Declare Attack", "Declare Block", "Damage Step", "Main Phase Two", "End Phase"]
    var currentPhase: Int = -1
    let activePlayerLabel = SKLabelNode(text: "")
    let phaseLabel = SKLabelNode(text: "")
    let tap = SKAction.rotate(byAngle: -(CGFloat.pi/4), duration: 0.5)
    let untap = SKAction.rotate(byAngle: (CGFloat.pi/4), duration: 0.5)
    var targetNeeded: Bool = false
    
    override func didMove(to view: SKView) {
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        layoutScene()
    }
    
    func layoutScene(){
        setUpGameStatusBar()
        background()
        playerOne()
        playerTwo()
        setStartingPlayer()
        currentPhase = 2
        updatePhaseLabel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.playGame()
        }
    }
    func setUpGameStatusBar(){
        let statusBar = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: frame.width, height: 40.0))
        statusBar.position = CGPoint(x: frame.midX, y: frame.midY)
        statusBar.zPosition = -1
        addChild(statusBar)
        
        activePlayerLabel.fontName = "Chalkboard SE Light"
        activePlayerLabel.fontSize = 14
        activePlayerLabel.fontColor = UIColor.black
        activePlayerLabel.position = CGPoint(x: statusBar.frame.midX, y: statusBar.frame.midY + 5)
        addChild(activePlayerLabel)
        
        phaseLabel.fontName = "Chalkboard SE Light"
        phaseLabel.fontSize = 14
        phaseLabel.fontColor = UIColor.black
        phaseLabel.position = CGPoint(x: statusBar.frame.midX, y: statusBar.frame.midY - 15)
        addChild(phaseLabel)
        
        p1NameLabel.text = "\(player1.name)"
        p1NameLabel.fontName = "Chalkboard SE Light"
        p1NameLabel.fontSize = 14
        p1NameLabel.fontColor = UIColor.black
        p1NameLabel.position = CGPoint(x: frame.minX + 24, y: statusBar.frame.midY - 5)
        p1NameLabel.zPosition = 0
        addChild(p1NameLabel)
        
        p1LifeLabel.fontName = "Chalkboard SE Light"
        p1LifeLabel.fontSize = 14
        p1LifeLabel.fontColor = UIColor.black
        p1LifeLabel.position = CGPoint(x: frame.minX + p1NameLabel.frame.width + 24, y: statusBar.frame.midY - 15)
        p1LifeLabel.zPosition = 0
        addChild(p1LifeLabel)
        
        let p1LifeTitle = SKLabelNode(text: "Life")
        p1LifeTitle.fontName = "Chalkboard SE Light"
        p1LifeTitle.fontSize = 14
        p1LifeTitle.fontColor = UIColor.black
        p1LifeTitle.position = CGPoint(x: frame.minX + p1NameLabel.frame.width + 24, y: statusBar.frame.midY + 5)
        p1LifeTitle.zPosition = 0
        addChild(p1LifeTitle)
        
        p2NameLabel.text = "\(player2.name)"
        p2NameLabel.fontName = "Chalkboard SE Light"
        p2NameLabel.fontSize = 14
        p2NameLabel.fontColor = UIColor.black
        p2NameLabel.position = CGPoint(x: frame.maxX - 24, y: statusBar.frame.midY - 5)
        p2NameLabel.zPosition = 0
        addChild(p2NameLabel)
        
        p2LifeLabel.fontName = "Chalkboard SE Light"
        p2LifeLabel.fontSize = 14
        p2LifeLabel.fontColor = UIColor.black
        p2LifeLabel.position = CGPoint(x: frame.maxX - p2NameLabel.frame.width - 24, y: statusBar.frame.midY - 15)
        p2LifeLabel.zPosition = 0
        addChild(p2LifeLabel)
        
        let p2LifeTitle = SKLabelNode(text: "Life")
        p2LifeTitle.fontName = "Chalkboard SE Light"
        p2LifeTitle.fontSize = 14
        p2LifeTitle.fontColor = UIColor.black
        p2LifeTitle.position = CGPoint(x: frame.maxX - p2NameLabel.frame.width - 24, y: statusBar.frame.midY + 5)
        p2LifeTitle.zPosition = 0
        addChild(p2LifeTitle)
    }
    
    func background(){
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -2
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = CGSize(width: frame.size.width, height: frame.size.height)
        addChild(background)
    }
    
    func playerOne(){
        self.p1LibraryName = GameViewController.p1LibraryName
        
        let p1Library = SKSpriteNode(imageNamed: "Magic_Card_Back")
        p1Library.name = "Library"
        p1Library.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.minY) + sceneYBuffer + elementHeight/2)
        p1Library.zPosition = 0
        p1Library.size = CGSize(width: elementWidth, height: elementHeight)
        p1GameItems.append(p1Library)
        addChild(p1Library)
        
        let p1Discard = SKSpriteNode(imageNamed: "add")
        p1Discard.name = "Discard Pile"
        p1Discard.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.minY) + sceneYBuffer + (elementHeight*3)/2 + 10)
        p1Discard.zPosition = 0
        p1Discard.size = CGSize(width: elementWidth, height: elementHeight)
        p1GameItems.append(p1Discard)
        addChild(p1Discard)
        
        let p1Exile = SKSpriteNode(imageNamed: "add")
        p1Exile.name = "Exile Pile"
        p1Exile.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.minY) + sceneYBuffer + (elementHeight*5)/2 + 20)
        p1Exile.zPosition = 0
        p1Exile.size = CGSize(width: elementWidth, height: elementHeight)
        p1GameItems.append(p1Exile)
        addChild(p1Exile)
    }
    
    func playerTwo(){
        let p2Library = SKSpriteNode(imageNamed: "Magic_Card_Back")
        p2Library.name = "Library"
        p2Library.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.maxY) - sceneYBuffer - elementHeight/2)
        p2Library.zPosition = 0
        p2Library.size = CGSize(width: elementWidth, height: elementHeight)
        p2GameItems.append(p2Library)
        addChild(p2Library)
        
        let p2Discard = SKSpriteNode(imageNamed: "add")
        p2Discard.name = "Discard Pile"
        p2Discard.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.maxY) - sceneYBuffer*3/2 - (elementHeight*3)/2 + 10)
        p2Discard.zPosition = 0
        p2Discard.size = CGSize(width: elementWidth, height: elementHeight)
        p2GameItems.append(p2Discard)
        addChild(p2Discard)
        
        let p2Exile = SKSpriteNode(imageNamed: "add")
        p2Exile.name = "Exile Pile"
        p2Exile.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.maxY) - sceneYBuffer*3/2 - elementHeight*5/2)
        p2Exile.zPosition = 0
        p2Exile.size = CGSize(width: elementWidth, height: elementHeight)
        p2GameItems.append(p2Exile)
        addChild(p2Exile)
    }
    
    func setStartingPlayer(){
        var p1Dice = Int(arc4random_uniform(UInt32(6))) + 1
        var p2Dice = Int(arc4random_uniform(UInt32(6))) + 1
        while p1Dice == p2Dice{
            p1Dice = Int(arc4random_uniform(UInt32(6))) + 1
            p2Dice = Int(arc4random_uniform(UInt32(6))) + 1
        }
        if p1Dice > p2Dice {
            player1.activePlayer = true
            activePlayerLabel.text = player1.name
        }else{
            player2.activePlayer = true
            activePlayerLabel.text = player2.name
        }
    }
    
    func setUpField(){
        buildLibrary(user: userID, libraryName: p1LibraryName, player: player1)
        buildLibrary(user: "Oliver", libraryName: "deckOne", player: self.player2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.player1.shuffleLibrary()
            self.player2.shuffleLibrary()
            for _ in 0..<7{
                self.player1.drawCard()
                self.player2.drawCard()
            }
            for i in 0..<7{
                var startX = Int(self.frame.minX) + self.sceneXBuffer + Int(self.p1GameItems[0].frame.width)
                startX += self.elementWidth*3/4*i
                let p1startY = Int(self.frame.minY) + self.sceneYBuffer
                let p2startY = Int(self.frame.maxY) - self.sceneYBuffer - Int(self.p1GameItems[0].frame.height)
                self.createHandNode(card: self.player1.hand.hand[i], player: self.player1, x: startX, y: p1startY)
                self.createHandNode(card: self.player2.hand.hand[i], player: self.player2, x: startX, y: p2startY)
                
            }
            self.p1LandX = Int(self.p1GameItems[3].position.x)
            self.p1LandY = Int(self.p1GameItems[1].position.y) + 40
            self.p1NonLandX = self.p1LandX
            
            self.p2LandX = Int(self.p2GameItems[3].position.x)
            self.p2LandY = Int(self.p2GameItems[1].position.y)
            self.p2NonLandX = self.p2LandX
        }
    }

    func buildLibrary(user: String, libraryName: String, player: Player){
        let libRef = ref.child("users/\(user)/collection/\(libraryName)/cards")
        if postHandle != nil {
            libRef.removeObserver(withHandle: self.postHandle)
        }
        postHandle = libRef.observe(DataEventType.childAdded, with: { (snapshot) in
            self.getData(dataRef: libRef.child("\(snapshot.key)/name"), type: "Name", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/image"), type: "Image", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/playType"), type: "Play Type", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/cardType"), type: "Card Type", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/castType"), type: "Cast Type", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/atk"), type: "Atk", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/def"), type: "Def", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/legendary"), type: "Legendary", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/color"), type: "Color", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/attributes"), type: "Attributes", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/subTypes"), type: "Sub Types", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/cost"), type: "Cost", player: player)
            self.getData(dataRef: libRef.child("\(snapshot.key)/loyaltyCounters"), type: "Loyalty Counters", player: player)
        })
    }
    
    func getData(dataRef: DatabaseReference, type: String, player: Player){
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if self.player1.name == player.name {
                if type == "Name" {
                    self.p1cardName.append(snapshot.value as! String)
                }else if type == "Image" {
                    self.p1image.append(snapshot.value as! String)
                }else if type == "Play Type"{
                    self.p1playType.append(snapshot.value as! String)
                }else if type == "Card Type"{
                    self.p1cardType.append(snapshot.value as! String)
                }else if type == "Cast Type"{
                    self.p1castType.append(snapshot.value as! String)
                }else if type == "Atk"{
                    self.p1atk.append(snapshot.value as? Int ?? 0)
                }else if type == "Def"{
                    self.p1def.append(snapshot.value as? Int ?? 0)
                }else if type == "Legendary"{
                    self.p1legendary.append(snapshot.value as! Bool)
                }else if type == "Color"{
                    self.p1color.append(snapshot.value as! String)
                }else if type == "Attributes"{
                    self.p1attributes.append((snapshot.value as! String).components(separatedBy: ","))
                }else if type == "Sub Types"{
                    self.p1subTypes.append((snapshot.value as! String).components(separatedBy: ","))
                }else if type == "Cost" {
                    self.p1Cost.append(snapshot.value as! Int)
                }else if type == "Loyalty Counters"{
                    self.p1LoyaltyCounters.append(snapshot.value as? Int ?? 0)
                }
            }else{
                if type == "Name" {
                    self.p2cardName.append(snapshot.value as! String)
                }else if type == "Image" {
                    self.p2image.append(snapshot.value as! String)
                }else if type == "Play Type"{
                    self.p2playType.append(snapshot.value as! String)
                }else if type == "Card Type"{
                    self.p2cardType.append(snapshot.value as! String)
                }else if type == "Cast Type"{
                    self.p2castType.append(snapshot.value as! String)
                }else if type == "Atk"{
                    self.p2atk.append(snapshot.value as? Int ?? 0)
                }else if type == "Def"{
                    self.p2def.append(snapshot.value as? Int ?? 0)
                }else if type == "Legendary"{
                    self.p2legendary.append(snapshot.value as! Bool)
                }else if type == "Color"{
                    self.p2color.append(snapshot.value as! String)
                }else if type == "Attributes"{
                    self.p2attributes.append((snapshot.value as! String).components(separatedBy: ","))
                }else if type == "Sub Types"{
                    self.p2subTypes.append((snapshot.value as! String).components(separatedBy: ","))
                }else if type == "Cost" {
                    self.p2Cost.append(snapshot.value as! Int)
                }else if type == "Loyalty Counters"{
                    self.p2LoyaltyCounters.append(snapshot.value as? Int ?? 0)
                }
            }
        })
    }
    
    func createHandNode(card: Cards, player: Player, x: Int, y: Int){
        let handNode = SKSpriteNode(imageNamed: card.image)
        handNode.name = card.name
        handNode.position = CGPoint(x: x + elementWidth/2, y: y + elementHeight/2)
        handNode.zPosition = 0
        handNode.size = CGSize(width: elementWidth, height: elementHeight)
        addChild(handNode)
        if player.name == player1.name {
            if player1.field.field.count == 0{
                p1GameItems.append(handNode)
            }else{
                p1GameItems.insert(handNode, at: player1.hand.hand.count + 2)
            }
        }else{
            if player2.field.field.count == 0{
                p2GameItems.append(handNode)
            }else{
                p2GameItems.insert(handNode, at: player2.hand.hand.count + 2)
            }
        }
    }

    func playGame(){
        if player1.activePlayer{
            playerOnesTurn()
        }else{
            //playerTwosTurn()
        }
    }
    
    func playerOnesTurn(){
        if currentPhase == 0{
            var fieldIndex = 3 + player1.hand.hand.count
            for card in player1.field.field{
                if card.tapped{
                    card.untap()
                    p1GameItems[fieldIndex].run(untap)
                }
                card.attacking = false
                card.blocked = false
                card.summoningSickness = false
                fieldIndex += 1
            }
            playTurn(x: Int(frame.midX), y: Int(frame.midY))
        }else if currentPhase == 1{
            if player1.library.library.count <= 0{
                showGameOverScene(user: "Oliver")
                print("Game Over! \(player1) has no cards left to draw. \(player2.name) Wins!")
            }else{
                var startXP1 = Int(self.frame.minX) + self.sceneXBuffer + Int(self.p1GameItems[0].frame.width)
                startXP1 += self.elementWidth*3/4*(player1.hand.hand.count)
                let startYP1 = Int(self.frame.minY) + self.sceneYBuffer
                player1.drawCard()
                createHandNode(card: player1.hand.hand.last!, player: player1, x: startXP1, y: startYP1)
            }
            playTurn(x: Int(frame.midX), y: Int(frame.midY))
        }else if currentPhase == 2 || currentPhase == 6{
            if p1Target > 2{
                if p1Target < player1.hand.hand.count + 3{
                    let cardIndex = p1Target - 3
                    let targetCard = player1.hand.hand[cardIndex]
                    let startX = p1GameItems[3].position.x
                    if !player1.playedLand && targetCard.cost == 0{
                        player1.playedLand = true
                        p1GameItems[p1Target].position = CGPoint(x: p1LandX+10, y: p1LandY)
                        p1GameItems.append(p1GameItems.remove(at: p1Target))
                        player1.playCard(card: targetCard)
                        for i in cardIndex..<player1.hand.hand.count{
                            let newX = Int(startX) + self.elementWidth*3/4*i
                            p1GameItems[p1Target].position.x = CGFloat(newX)
                            p1Target += 1
                        }
                        if p1LandY == Int(p1GameItems[1].position.y) {
                            p1LandY = Int(p1GameItems[1].position.y) + 40
                            p1LandX += Int(p1GameItems[4].position.x - p1GameItems[3].position.x)
                        }else{
                            p1LandY -= 20
                        }
                    }else if targetCard.cost > 0 && p1ManaPool >= targetCard.cost && (targetCard.cardType == "Creature" || targetCard.cardType == "Artifact Creature"){
                        p1GameItems[p1Target].position = CGPoint(x: p1NonLandX+10, y: Int(frame.midY) - elementHeight + 20)
                        p1GameItems.append(p1GameItems.remove(at: p1Target))
                        player1.field.add(card: player1.hand.remove(card: targetCard)!)
                        for i in cardIndex..<player1.hand.hand.count{
                            let newX = Int(startX) + self.elementWidth*3/4*i
                            p1GameItems[p1Target].position.x = CGFloat(newX)
                            p1Target += 1
                        }
                        p1NonLandX += elementWidth + 10
                        p1ManaPool -= targetCard.cost
                    }
                }else{
                    let cardIndex = p1Target - 3 - player1.hand.hand.count
                    let targetCard = player1.field.field[cardIndex]
                    if targetCard.cost == 0 && !targetCard.tapped{
                        targetCard.tap()
                        p1GameItems[p1Target].run(tap)
                        p1ManaPool += 1
                    }
                }
            }
        }else if currentPhase == 3{
            if p1Target >= player1.hand.hand.count + 3{
                let cardIndex = p1Target - 3 - player1.hand.hand.count
                let targetCard = player1.field.field[cardIndex]
                var vigilance = false
                for attribute in targetCard.attributes{
                    if attribute == "Vigilance" {
                        vigilance = true
                    }
                }
                if (targetCard.cardType == "Creature" || targetCard.cardType == "Artifact Creature") && !targetCard.tapped && (!targetCard.summoningSickness){
                    if !vigilance{
                        targetCard.tap()
                        p1GameItems[p1Target].run(tap)
                    }
                    targetCard.attacking = true
                }
            }
        }else if currentPhase == 4{
            
        }else if currentPhase == 5{
            for card in player1.field.field{
                for attribute in card.attributes{
                    if attribute == "Lifelink"{
                        p1Life += card.atk!
                    }
                }
                if card.attacking && !card.blocked{
                    p2Life -= card.atk!
                }else if (card.attacking && card.blocked){
                    p2Life -= card.damage
                }
            }
            if player2.life <= 0 {
                showGameOverScene(user: userID)
                print("Game Over! \(player2.name) has 0 life. \(player1.name) Wins!")
            }
        }else{
            if player1.hand.hand.count > 7{
                targetNeeded = true
                if p1Target < player1.hand.hand.count + 3 && p1Target > 2{
                    let cardIndex = p1Target - 3
                    let targetCard = player1.hand.hand[cardIndex]
                    let startX = p1GameItems[3].position.x
                    p1GameItems.remove(at: p1Target)
                    player1.discardCard(card: targetCard)
                    p1GameItems[1].texture = SKTexture(imageNamed: targetCard.image)
                    for i in cardIndex..<player1.hand.hand.count{
                        let newX = Int(startX) + self.elementWidth*3/4*i
                        p1GameItems[p1Target].position.x = CGFloat(newX)
                        p1Target += 1
                    }
                }
            }else{
                targetNeeded = false
                playTurn(x: Int(frame.midX), y: Int(frame.midY))
            }
        }
        p1Target = -1
        p2Target = -1
    }
    
    func playerTwosTurn(){
        if currentPhase == 0{
            var fieldIndex = 3 + player2.hand.hand.count
            for card in player2.field.field{
                if card.tapped{
                    card.untap()
                    p2GameItems[fieldIndex].run(untap)
                }
                card.attacking = false
                card.blocked = false
                fieldIndex += 1
            }
            playTurn(x: Int(frame.midX), y: Int(frame.midY))
        }else if currentPhase == 1{
            if player2.library.library.count <= 0{
                showGameOverScene(user: self.userID)
                print("Game Over! \(player2) has no cards left to draw. \(player1.name) Wins!")
            }else{
                var p2startX = Int(self.frame.minX) + self.sceneXBuffer + Int(self.p2GameItems[0].frame.width)
                p2startX += self.elementWidth*3/4*(player2.hand.hand.count)
                let startYP2 = Int(self.frame.maxY) - self.sceneYBuffer - elementHeight
                player1.drawCard()
                createHandNode(card: player2.hand.hand.last!, player: player2, x: p2startX, y: startYP2)
            }
            playTurn(x: Int(frame.midX), y: Int(frame.midY))
        }else if currentPhase == 2 || currentPhase == 6{
            
        }else if currentPhase == 3{
            
        }else if currentPhase == 4{
            
        }else if currentPhase == 5{
            if(player2.life <= 0){
                showGameOverScene(user: self.userID)
                print("Game Over! \(player2.name) has 0 life. \(player1.name) Wins!")
            }
        }else{
            if player2.hand.hand.count > 7{
                let node = p2GameItems.remove(at: player2.hand.hand.count + 2)
                p2GameItems[1].texture = node.texture
                player2.discardCard(card: player2.hand.hand.last!)
            }else{
                playTurn(x: Int(frame.midX), y: Int(frame.midY))
            }
        }
    }
    
    func changeActivePlayer(){
        if player1.activePlayer{
            player1.playedLand = false
            player1.activePlayer = false
            player2.activePlayer = true
            p1ManaPool = 0
            activePlayerLabel.text = player2.name
        }else{
            player1.activePlayer = true
            player2.activePlayer = false
            player2.playedLand = false
            p2ManaPool = 0
            activePlayerLabel.text = player1.name
            if player2.hand.hand.count > 7{
                //player2.discardCard(card: <#T##Cards#>)
            }
        }
    }
    
    func updatePhaseLabel(){
        if currentPhase == gamePhases.count{
            changeActivePlayer()
            currentPhase = 0
        }
        phaseLabel.text = gamePhases[currentPhase]
    }

    func showGameOverScene(user: String){
        var p1Coins = 0
        self.ref.child("users/\(userID)/coins").observeSingleEvent(of: .value) { (snapshot) in
            p1Coins = snapshot.value as! Int
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if user == "Oliver"{
                self.ref.child("users/\(self.userID)/coins").setValue(p1Coins + 2)
            }else{
                self.ref.child("users/\(self.userID)/coins").setValue(p1Coins + 10)
            }
        }
        let gameOverScene = GameOverScene(size: (scene?.view?.bounds.size)!)
        self.scene?.view?.presentScene(gameOverScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let location = touch.location(in: self.view)
        
        let x: Int = Int(location.x)
        let y: Int = Int(location.y)
        
        playTurn(x: x, y: y)
    }
    
    func playTurn(x: Int, y: Int){
        let offsetX = elementWidth/2
        let offsetY = elementHeight/2
        
        if x >= Int(frame.midX) - 50 && x <= Int(frame.midX) + 50 && y >= Int(frame.midY) - 20 && y <= Int(frame.midY) + 20 && !targetNeeded{
            currentPhase += 1
            updatePhaseLabel()
        }
        if y > Int(frame.midY) - 20{
            for i in 0..<p1GameItems.count{
                let itemX = Int(p1GameItems[i].position.x)
                let itemY = Int(frame.maxY - p1GameItems[i].position.y)
                if x >= itemX - offsetX && x <= itemX + offsetX && y >= itemY - offsetY && y <= itemY + offsetY{
                    p1Target = i
                    break
                }
            }
        }
        if y < Int(frame.midY) + 20{
            for i in 0..<p2GameItems.count{
                let itemX = Int(p2GameItems[i].position.x)
                let itemY = Int(frame.maxY - p2GameItems[i].position.y)
                if x >= itemX - offsetX && x <= itemX + offsetX && y >= itemY - offsetY && y <= itemY + offsetY{
                    p2Target = i
                    break
                }
            }
        }
        playGame()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
