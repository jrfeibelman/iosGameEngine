//
//  GameScene.swift
//  Swift Game
//
//  Created by Jason Feibelman on 12/28/17.
//  Copyright © 2017 Feibs. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player : Player?
    
    private var terrain = Terrain()
    private let terrainSize : UInt8 = 7
    
    private let plotsOnScreen = 4
    
    private var isAlive = false
    
    private var pausePanel = SKSpriteNode()
    
    private var gamePaused = false
    private var showingWorldEnd = false
    
    private let cursor = SKSpriteNode(imageNamed: "cursor")
    private let walkArrow = SKSpriteNode(imageNamed: "arrow")
    private let sprintArrow = SKSpriteNode(imageNamed: "arrow")
    
    private let movementGUIScale : CGFloat = 3;
    private let defaultAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        self.scaleMode = .resizeFill
        
        cursor.setScale(movementGUIScale)
        walkArrow.setScale(movementGUIScale)
        sprintArrow.setScale(movementGUIScale)
        
        cursor.anchorPoint = CGPoint(x: 0, y: 0)
        walkArrow.anchorPoint = CGPoint(x: 0, y: 0)
        sprintArrow.anchorPoint = CGPoint(x: 0, y: 0)
        
        cursor.zPosition = 10
        walkArrow.zPosition = 10
        sprintArrow.zPosition = 10
        
        isAlive = true
        
        self.terrain = Terrain(size: Int(terrainSize), scene: self)
        
        createPlayer()
        createBG()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Plot" {
            let plot = secondBody.node as! Plot
            player!.plotPos = plot.getID()
        }
    
        if firstBody.node?.name == "Player" && secondBody.node?.name == "PlotEnd" {
            if player!.rightDir {
                player!.worldPos = WorldPosition.rightEnd
            } else {
                player!.worldPos = WorldPosition.leftEnd
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "PlotEnd" {
            if player!.worldPos != WorldPosition.inWorld {
                player!.worldPos = WorldPosition.inWorld
            }
        }
    }

    private func createPlayer() {
        player = Player(plotPos: Int(self.terrain.mapSize/2))
        player!.position = CGPoint(x: 0, y: 0)
        self.addChild(player!)
    }
    
    private func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = -100
            self.addChild(bg)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if player!.getMovement() != MovementType.still {
            moveBackgroundsAndGrounds(sprinting: player!.getMovement() == MovementType.sprint, right: player!.isMovingRight())
        }
    }
    
    private func moveBackgroundsAndGrounds(sprinting : Bool, right : Bool) {
        
        var foreSpeed : CGFloat = 5
        var backSpeed : CGFloat = 1.5
        
        if sprinting {
            foreSpeed /= player!.getSprintRatio()
            backSpeed /= player!.getSprintRatio()
        }
        
        if !right {
            
            if player!.worldPos == WorldPosition.leftEnd {
                foreSpeed = 0
                backSpeed = 0
            }
            
            foreSpeed *= -1
            backSpeed *= -1
            
        } else {
            
            if player!.worldPos == WorldPosition.rightEnd {
                foreSpeed = 0
                backSpeed = 0
            }
        }
        
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode
            
            bgNode.position.x -= backSpeed
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3
            } else if bgNode.position.x > (self.frame.width) {
                bgNode.position.x -= bgNode.size.width * 3
            }
        }))
        
        enumerateChildNodes(withName: "PlotEnd", using: ({
            (node, error) in
            self.movePlot(plot: node as! Plot, speed: foreSpeed)
        }))
        
        enumerateChildNodes(withName: "Plot", using: ({
            (node, error) in
            self.movePlot(plot: node as! Plot, speed: foreSpeed)
        }))
    }
    
    func movePlot(plot : Plot, speed : CGFloat) {
        
        plot.position.x -= speed
        
        if self.player!.rightDir && plot.position.x < -1 * self.frame.width/2 - plot.size.width { // going right
            
            plot.removeFromParent()
            
            print("left-remove: " + String(plot.getID()))
            
            if plot.getID() + self.plotsOnScreen <= self.terrain.mapSize - 1 {
                self.terrain.showPlot(id: plot.getID() + self.plotsOnScreen, right: true)
            }
            
        } else if !self.player!.rightDir && plot.position.x > self.frame.width/2 { // going left
            
            plot.removeFromParent()
            
            print("right-remove: " + String(plot.getID()))
            
            if plot.getID() - self.plotsOnScreen >= 0 {
                self.terrain.showPlot(id: plot.getID() - self.plotsOnScreen, right: false)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
//            if atPoint(location).name == "Restart" {
//                let gameplay = GameScene(fileNamed: "GameScene")
//                gameplay!.scaleMode = .aspectFill
//                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
//            }
            
//            if atPoint(location).name == "Quit" {
//                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")
//                mainMenu!.scaleMode = .aspectFill
//                self.view?.presentScene(mainMenu!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
//            }
            
            if atPoint(location).name == "Pause" {
                createPausePanel()
            }
            
            if atPoint(location).name == "Resume" {
                pausePanel.removeFromParent()
                self.scene?.isPaused = false
                isPaused = false
                
            }
            
            if atPoint(location).name == "Quit" {
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")
                mainMenu!.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            
        }
        
        if !gamePaused {
            let loc = touches.first!.location(in: self)
            cursor.position = loc
            
            walkArrow.isHidden = true
            sprintArrow.isHidden = true
            
            self.addChild(cursor)
            self.addChild(walkArrow)
            self.addChild(sprintArrow)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        print(cursor.position)
        
        if !gamePaused {
            let loc = touches.first!.location(in: self)
            
            if loc.x > cursor.position.x + 90 { // Sprint Right
                walkArrow.isHidden = false
                sprintArrow.isHidden = false
                sprintArrow.xScale = movementGUIScale
                walkArrow.xScale = movementGUIScale
                sprintArrow.position = CGPoint(x: cursor.position.x + 120, y: cursor.position.y + cursor.size.width/2  - walkArrow.size.height/2)
                walkArrow.position = CGPoint(x: cursor.position.x + 60, y: cursor.position.y + cursor.size.width/2 - walkArrow.size.height/2)
                player!.move(sprinting: true, right: true)
            } else if loc.x > cursor.position.x + 20 { // Right
                sprintArrow.isHidden = true
                walkArrow.isHidden = false
                walkArrow.xScale = movementGUIScale
                walkArrow.position = CGPoint(x: cursor.position.x + 60, y: cursor.position.y + cursor.size.width/2 - walkArrow.size.height/2)
                player!.move(sprinting: false, right: true)
            } else if loc.x < cursor.position.x - 90 { // Sprint Left
                walkArrow.isHidden = false
                sprintArrow.isHidden = false
                sprintArrow.xScale = movementGUIScale *  -1
                walkArrow.xScale = movementGUIScale * -1
                sprintArrow.position = CGPoint(x: cursor.position.x - 120, y: cursor.position.y + cursor.size.width/2  - walkArrow.size.height/2)
                walkArrow.position = CGPoint(x: cursor.position.x - 60, y: cursor.position.y + cursor.size.width/2  - walkArrow.size.height/2)
                player!.move(sprinting: true, right: false)
            } else if loc.x < cursor.position.x - 20 { // Left
                sprintArrow.isHidden = true
                walkArrow.isHidden = false
                walkArrow.xScale = movementGUIScale * -1
                walkArrow.position = CGPoint(x: cursor.position.x - 60, y: cursor.position.y + cursor.size.width/2  - walkArrow.size.height/2)
                player!.move(sprinting: false, right: false)
            } else { // Not Moving
                walkArrow.isHidden = true
                sprintArrow.isHidden = true
                player!.stopMoving()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gamePaused {
            cursor.removeFromParent()
            walkArrow.removeFromParent()
            sprintArrow.removeFromParent()
            player!.stopMoving()
        }
    }
    
    
//    private func randomBetweenNumbers(_ firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
//
//        // arc4random returns a number between 0 to (2**32)-1
//        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber);
//
//    }
    
    private func createPausePanel() {
        
        gamePaused = true
        
        self.scene?.isPaused = true
        
//        player.removeAllActions()
        
        pausePanel = SKSpriteNode(imageNamed: "Pause Panel")
        pausePanel.anchorPoint = defaultAnchorPoint
        pausePanel.position = CGPoint(x: 0, y: 0)
        pausePanel.zPosition = 10
        
        let resume = SKSpriteNode(imageNamed: "Play")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        resume.name = "Resume"
        resume.anchorPoint = defaultAnchorPoint
        resume.position = CGPoint(x: -155, y: 0)
        resume.setScale(0.75)
        resume.zPosition = 9
        
        quit.name = "Quit"
        quit.anchorPoint = defaultAnchorPoint
        quit.position = CGPoint(x: 155, y: 0)
        quit.setScale(0.75)
        quit.zPosition = 9
        
        pausePanel.addChild(resume)
        pausePanel.addChild(quit)
        
        self.addChild(pausePanel)
        
    }
    
    private func unPauseGame() {
        gamePaused = false;
    }
    
}
