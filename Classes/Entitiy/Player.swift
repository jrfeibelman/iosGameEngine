//
//  Player.swift
//  Beyond Worlds
//
//  Created by Jason Feibelman on 6/2/19.
//  Copyright © 2019 FiBEL. All rights reserved.
//

import SpriteKit

struct ColliderType {
    static let Player: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Obstacle: UInt32 = 3
}

enum MovementType {
    case still
    case walk
    case sprint
}

enum WorldPosition : Int8 {
    case leftEnd = -2
    case rightEnd = -1
    case inWorld = 0
}

class Player: SKSpriteNode {
    
    private let playerScale : CGFloat
    private let sprintRatio : CGFloat = 1/2
    
    private let walkAnimation : SKAction
    private let sprintAnimation : SKAction
    
    private var movement = MovementType.still
    
    public var worldPos = WorldPosition.inWorld
    
    // Approximation of the plot the player is on
    public var plotPos : Int
    
    public var rightDir = true
    
    private var coins : UInt8 = 0
    
    init(plotPos : Int) {
        
        self.playerScale = 5
        self.plotPos = plotPos
        
        var walk = [SKTexture]()
        
        for i in 1...6 {
            let name = "Leader\(i)"
            walk.append(SKTexture(imageNamed: name))
        }
        
        walkAnimation = SKAction.animate(with: walk, timePerFrame: TimeInterval(0.092), resize: true, restore: true)
        sprintAnimation = SKAction.animate(with: walk, timePerFrame: TimeInterval(sprintRatio * 0.092), resize: true, restore: true)
        
        super.init(texture: walk[1], color: UIColor.clear, size: walk[1].size())
        
        
        self.name = "Player"
        self.zPosition = 2
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setScale(playerScale)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width/2 - 20, height: self.size.height))
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(sprinting: Bool, right: Bool) {
        
        rightDir = right

        if sprinting {
            if movement != MovementType.sprint {
                self.removeAction(forKey: "playerWalk")
                self.run(SKAction.repeatForever(sprintAnimation), withKey: "playerSprint")
                self.movement = MovementType.sprint
            }
        } else {
            if movement != MovementType.walk {
                self.removeAction(forKey: "playerSprint")
                self.run(SKAction.repeatForever(walkAnimation), withKey: "playerWalk")
                self.movement = MovementType.walk
            }
        }

        if !rightDir {
            self.xScale = self.playerScale * -1
        } else {
            self.xScale = self.playerScale
        }

    }
    
    func stopMoving() {
        self.removeAction(forKey: "playerWalk")
        self.removeAction(forKey: "playerSprint")
        self.movement = MovementType.still
    }
    
    func jump() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 240))
    }
    
    func getMovement() -> MovementType {
        return self.movement
    }
    
    func getSprintRatio() -> CGFloat {
        return self.sprintRatio
    }
    
    func isMovingRight() -> Bool {
        return self.rightDir
    }
    
}
