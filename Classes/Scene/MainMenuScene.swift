//
//  MainMenuScene.swift
//  Beyond Worlds
//
//  Created by Jason Feibelman on 6/3/19.
//  Copyright © 2019 FiBEL. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var playBtn = SKSpriteNode()
    var scoreBtn = SKSpriteNode()
    
    var title = SKLabelNode()
    
    var scoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        initialize()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveBackgroundsAndGrounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == playBtn {
                let gameplay = GameScene(fileNamed: "GameScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            
            if atPoint(location) == scoreBtn {
                showScore()
            }
            
        }
        
    }
    
    func initialize() {
        createBG()
        createGrounds()
        getButtons()
        getLabel()
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = 0
            self.addChild(bg)
        }
    }
    
    func createGrounds() {
        for i in -1...2 {
            let bg = SKSpriteNode(imageNamed: "terrain")
            bg.name = "Ground"
            bg.setScale(2.4)
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2) + bg.size.height/2)
            bg.zPosition = 3
            self.addChild(bg)
        }
    }
    
    func moveBackgroundsAndGrounds() {
        
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode
            
            bgNode.position.x -= 2
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3
            }
            
        }))
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode
            
            bgNode.position.x -= 3
            
            if bgNode.position.x < -(self.frame.width - 7*bgNode.size.width/8) {
                bgNode.position.x += bgNode.size.width * 4
            }
            
        }))
        
    }
    
    func getButtons() {
        playBtn = self.childNode(withName: "Play") as! SKSpriteNode
        scoreBtn = self.childNode(withName: "Score") as! SKSpriteNode
    }
    
    func getLabel() {
        title = self.childNode(withName: "Title") as! SKLabelNode
        
//       title.fontName = "NewYork.otf"
        title.fontSize = 120
        title.text = "Beyond Worlds"
        
        title.zPosition = 5
        
        let moveUp = SKAction.moveTo(y: title.position.y + 50, duration: TimeInterval(1.3))
        
        let moveDown = SKAction.moveTo(y: title.position.y - 50, duration: TimeInterval(1.3))
        
        let sequence = SKAction.sequence([moveUp, moveDown])
        
        title.run(SKAction.repeatForever(sequence))
        
    }
    
    func showScore() {
        scoreLabel.removeFromParent()

        scoreLabel = SKLabelNode(fontNamed: "NewYork.otf")
        scoreLabel.fontSize = 180
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "Highscore"))"
        scoreLabel.position = CGPoint(x: 0, y: -200)
        scoreLabel.zPosition = 9
        self.addChild(scoreLabel)
    }
    
}
