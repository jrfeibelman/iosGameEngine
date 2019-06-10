//
//  MapGenerator.swift
//  Beyond Worlds
//
//  Created by Jason Feibelman on 6/5/19.
//  Copyright © 2019 FiBEL. All rights reserved.
//

import SpriteKit

class Terrain {
    
    private var terrain : [Plot?]
    public var mapSize : Int
    private var scene : GameScene?
    
    init() {
        terrain = []
        mapSize = 9
    }

    init(size : Int, scene : GameScene) {
        
        self.mapSize = size + 4 // Add 4 for world end tiles
        
        if mapSize % 2 == 0 {
            self.mapSize = size - 1
        }
        
        if mapSize < 9 {
            fatalError("MapSize cannot be less than 9!")
        }
        
        self.scene = scene
        
        terrain = Array<Plot?>(repeating: nil, count: mapSize)
        
        for i in 0...mapSize-1 {
            if i <= 1 || i >= mapSize - 2 {
                self.terrain[i] = Plot(terrainType: TerrainType.worldEnd, buildingType: BuildingType.empty, doublePlot: false, id: i)
            } else {
                self.terrain[i] = Plot(terrainType: TerrainType.grass, buildingType: BuildingType.empty, doublePlot: false, id: i)
            }
        }
        
        if let spawnPoint = terrain[mapSize/2] {
            spawnPoint.setPlot(buildingType: BuildingType.townHall, doublePlot: true)
        }
        
        createTerrain()
    }
    
    func createTerrain() {
        for i in -2...1 {
            if let plot = terrain[mapSize/2 + i] {
                self.scene!.addChild(plot)
                plot.initSprite(pos: i)
            } else {
                fatalError("No Plot Available!")
            }
        }
    }
    
    func showPlot(id : Int, right : Bool) {
        let plot = terrain[id]!
        
        self.scene?.addChild(plot)
        
        if right {
            print("right-add: " + String(id))
            let prevPlot = terrain[id-1]!
            plot.position.y = prevPlot.position.y
            plot.position.x = prevPlot.position.x + plot.size.width - 10
        } else {
            print("left-add: " + String(id))
            let prevPlot = terrain[id+1]!
            plot.position.y = prevPlot.position.y
            plot.position.x = prevPlot.position.x - plot.size.width + 10
        }
    }
    
    func printTerrainToConsole() {
        print(self.terrain)
    }
}
