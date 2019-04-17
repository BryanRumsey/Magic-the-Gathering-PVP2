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
class GameScene: SKScene {
    
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
            p1LifeLabel.text = "\(p1Life)"
        }
    }
    
    var player2: Player = Player(name: "Oliver")
    let p2NameLabel = SKLabelNode(text: "Player 2")
    let p2LifeLabel = SKLabelNode(text: "20")
    var p2Life: Int = 20 {
        didSet{
            p2LifeLabel.text = "\(p1Life)"
        }
    }
    
    //Card variables
    var i = 0
    var cardName: [String] = []
    var image: [String] = []
    var playType: [String] = []
    var cardType: [String] = []
    var castType: [String] = []
    var atk: [Int] = []
    var def: [Int] = []
    var legendary: [Bool] = []
    var color: [String] = []
    var attributes: [[String]] = []
    var subTypes: [[String]] = []
    var p1LoyaltyCounters: [Int] = []{
        didSet{
            let card = Cards(name: self.cardName[i], image: self.image[i], playType: self.playType[i], castType: self.castType[i], cardType: self.cardType[i], atk: self.atk[i], def: self.def[i], legendary: self.legendary[i], color: self.color[i], attributes: self.attributes[i], subTypes: self.subTypes[i], loyaltyCoiunters: self.p1LoyaltyCounters[i])
            player1.library.add(card: card)
            self.i += 1
        }
    }
    var p2LoyaltyCounters: [Int] = []{
        didSet{
            let card = Cards(name: self.cardName[i], image: self.image[i], playType: self.playType[i], castType: self.castType[i], cardType: self.cardType[i], atk: self.atk[i], def: self.def[i], legendary: self.legendary[i], color: self.color[i], attributes: self.attributes[i], subTypes: self.subTypes[i], loyaltyCoiunters: self.p1LoyaltyCounters[i])
            player2.library.add(card: card)
            self.i += 1
        }
    }
    
    var gamePhases: [String] = ["Untap Phase", "Draw Phase", "Main Phase One", "Declare Attack", "Declare Block", "Damage Step", "Main Phase Two", "End Phase"]
    var currentPhase: Int = -1
    var gameItems: [SKSpriteNode] = []
    var target: Int = -1
    
    override func didMove(to view: SKView) {
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        layoutScene()
    }
    
    func layoutScene(){
        setUpGameStatusBar()
        background()
        playerOne()
    }
    func setUpGameStatusBar(){
        let statusBar = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: frame.width, height: 40.0))
        statusBar.position = CGPoint(x: frame.midX, y: frame.midY)
        statusBar.zPosition = -1
        addChild(statusBar)
        
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
        gameItems.append(p1Library)
        addChild(p1Library)
        
        let p1Discard = SKSpriteNode(imageNamed: "add")
        p1Discard.name = "Discard Pile"
        p1Discard.position = CGPoint(x: Int(frame.minX) + sceneXBuffer + elementWidth/2, y: Int(frame.minY) + sceneYBuffer + (elementHeight*3)/2 + 10)
        p1Discard.zPosition = 0
        p1Discard.size = CGSize(width: elementWidth, height: elementHeight)
        gameItems.append(p1Discard)
        addChild(p1Discard)
        
        let p1Exile = SKSpriteNode(imageNamed: "add")
        p1Exile.name = "Exile Pile"
        p1Exile.position = CGPoint(x: Int(frame.maxX) - sceneXBuffer - elementWidth/2, y: Int(frame.minY) + sceneYBuffer + elementHeight/2)
        p1Exile.zPosition = 0
        p1Exile.size = CGSize(width: elementWidth, height: elementHeight)
        gameItems.append(p1Exile)
        addChild(p1Exile)
    }
    
    func playerTwo(){
        
    }
    
    func setUpField(){
        buildLibrary(user: userID, libraryName: p1LibraryName, player: player1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            self.player1.shuffleLibrary()
            for i in 0..<7{
                self.player1.drawCard()
                //add hand images to field
            }
            self.playGame()
        }
        //buildLibrary(user: "Oliver", libraryName: "deckOne", player: player2)
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
        //    self.player2.shuffleLibrary()
        //    for _ in 0..<7{
        //        self.player2.drawCard()
        //    }
        //}
    }

    func buildLibrary(user: String, libraryName: String, player: Player){
        let libRef = ref.child("users/\(user)/collection/\(libraryName)/cards")
        if postHandle != nil {
            libRef.removeObserver(withHandle: self.postHandle)
        }
        if player.name == player2.name {
            libRef.child("users/\(user)/collection/\(libraryName)/cards")
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
            self.getData(dataRef: libRef.child("\(snapshot.key)/loyaltyCounters"), type: "Loyalty Counters", player: player)
        })
    }
    
    func getData(dataRef: DatabaseReference, type: String, player: Player){
        dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if type == "Name" {
                self.cardName.append(snapshot.value as! String)
            }else if type == "Image" {
                self.image.append(snapshot.value as! String)
            }else if type == "Play Type"{
                self.playType.append(snapshot.value as! String)
            }else if type == "Card Type"{
                self.cardType.append(snapshot.value as! String)
            }else if type == "Cast Type"{
                self.castType.append(snapshot.value as! String)
            }else if type == "Atk"{
                self.atk.append(snapshot.value as? Int ?? 0)
            }else if type == "Def"{
                self.def.append(snapshot.value as? Int ?? 0)
            }else if type == "Legendary"{
                self.legendary.append(snapshot.value as! Bool)
            }else if type == "Color"{
                self.color.append(snapshot.value as! String)
            }else if type == "Attributes"{
                self.attributes.append((snapshot.value as! String).components(separatedBy: ","))
            }else if type == "Sub Types"{
                self.subTypes.append((snapshot.value as! String).components(separatedBy: ","))
            }else if type == "Loyalty Counters" && self.player1.name == player.name{
                self.p1LoyaltyCounters.append(snapshot.value as? Int ?? 0)
            }else if type == "Loyalty Counters" && self.player2.name == player.name{
                self.p2LoyaltyCounters.append(snapshot.value as? Int ?? 0)
            }
        })
    }

    func playGame(){
        currentPhase = 2
        
        if gamePhases[currentPhase] == "End Phase"{
            changeActivePlayer()
            currentPhase = 0
        }
    }
    
    func changeActivePlayer(){
        if player1.activePlayer{
            player1.playedLand = false
            player1.activePlayer = false
            player2.activePlayer = true
            if player1.hand.hand.count > 7{
                //player1.discardCard(card: <#T##Cards#>)
            }
        }else{
            player1.activePlayer = true
            player2.activePlayer = false
            player2.playedLand = false
            if player2.hand.hand.count > 7{
                //player2.discardCard(card: <#T##Cards#>)
            }
        }
    }


    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let location = touch.location(in: self.view)
        
        let x = Int(location.x)
        let offsetX = elementWidth/2
        let y = Int(location.y)
        let offsetY = elementHeight/2
        
        for i in 0..<gameItems.count{
            let itemX = Int(gameItems[i].position.x)
            let itemY = Int(frame.maxY - gameItems[i].position.y)
            if x >= itemX - offsetX && x <= itemX + offsetX && y >= itemY - offsetY && y <= itemY + offsetY{
                print(gameItems[i].name!)
            }
        }
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
