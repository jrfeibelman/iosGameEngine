//
//  Plot.swift
//  Beyond Worlds
//
//  Created by Jason Feibelman on 6/5/19.
//  Copyright © 2019 FiBEL. All rights reserved.
//

import SpriteKit

enum TerrainType : Int8 {
    case worldEnd = -1
    case grass = 0
    case sand = 1
    case water = 2
}

enum BuildingType : UInt8 {
    case empty = 0
    case townHall = 1
}

class Plot : SKSpriteNode {
    
    private var terrainType : TerrainType
    private var buildingType : BuildingType
    
    private var doublePlot : Bool
    private var buildable = false
    
    private let plotScale : CGFloat = 2.4
    
    private let id : Int
    private let myLabel : SKLabelNode
    
    init(terrainType : TerrainType, buildingType : BuildingType, doublePlot : Bool, id: Int) {
        
        self.terrainType = terrainType
        self.buildingType = buildingType
        self.doublePlot = doublePlot
        
        self.id = id
        
        myLabel = SKLabelNode()
        myLabel.fontColor = UIColor.white
        myLabel.text = String(self.id)
        myLabel.fontSize = 60
        myLabel.zPosition = 20
        
        let tx : SKTexture
        
        if terrainType == TerrainType.worldEnd {
            tx = SKTexture(imageNamed: "Ground-1")
        } else {
            tx = SKTexture(imageNamed: "terrain")
        }
        
        super.init(texture: tx, color: UIColor.clear, size: CGSize(width: tx.size().width, height: tx.size().height))
        
        self.name = "Plot"
        self.setScale(plotScale)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size.applying(CGAffineTransform.init(scaleX: 1, y: 0.85)))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = ColliderType.Ground
        
        self.addChild(myLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSprite(pos : Int) {
        self.position = CGPoint(x: CGFloat(pos) * self.size.width, y: -(scene!.frame.size.height / 2) + self.size.height/2)
        
        myLabel.position = self.position
        myLabel.position.y = scene!.frame.size.height/3 - 3 * self.size.height / 2
    }
    
    func getID() -> Int {
        return self.id
    }
    
    func setBuildable(_ buildable : Bool) {
        self.buildable = buildable
    }
    
    func setPlot(buildingType : BuildingType, doublePlot : Bool) {
        self.buildingType = buildingType
        self.doublePlot = doublePlot
    }
}
