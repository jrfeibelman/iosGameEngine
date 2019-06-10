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
    
    init(terrainType : TerrainType, buildingType : BuildingType, doublePlot : Bool, id: Int) {
        
        self.terrainType = terrainType
        self.buildingType = buildingType
        self.doublePlot = doublePlot
        
        self.id = id
        
        let tx : SKTexture
        
        if terrainType == TerrainType.worldEnd {
            tx = SKTexture(imageNamed: "terrainEnd")
        } else {
            tx = SKTexture(imageNamed: "terrain")
        }
        
        super.init(texture: tx, color: UIColor.clear, size: CGSize(width: tx.size().width, height: tx.size().height))
        
        if terrainType == TerrainType.worldEnd {
            self.name = "PlotEnd"
        } else {
            self.name = "Plot"
        }
        
        self.setScale(plotScale)
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.zPosition = 3
        
        if self.terrainType == TerrainType.worldEnd {
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size.applying(CGAffineTransform.init(scaleX: 1, y: 5)), center: CGPoint(x: self.position.x + self.size.width/2, y: self.position.y))
        } else {
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size.applying(CGAffineTransform.init(scaleX: 1, y: 1.8)), center: CGPoint(x: self.position.x + self.size.width/2, y: self.position.y))
        }
        
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = ColliderType.Ground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSprite(pos : Int) {
        self.position = CGPoint(x: CGFloat(pos) * self.size.width, y: -(scene!.frame.size.height / 2))
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
