//
//  MapGenerator.swift
//  Beyond Worlds
//
//  Created by Jason Feibelman on 6/5/19.
//  Copyright © 2019 FiBEL. All rights reserved.
//

import Foundation

class Terrain {
    
    private var terrain : [Plot?]
    private var mapSize : Int
    private var scene : GameScene?
    
    init() {
        terrain = []
        mapSize = 5
    }

    init(size : Int, scene : GameScene) {
        
        self.mapSize = size
        
        if mapSize % 2 == 0 {
            self.mapSize = size - 1
        }
        
        if mapSize < 5 {
            fatalError("MapSize cannot be less than 5!")
        }
        
        self.scene = scene
        
        terrain = Array<Plot?>(repeating: nil, count: mapSize)
        
        for i in 0...mapSize-1 {
            self.terrain[i] = Plot(terrainType: TerrainType.grass, buildingType: BuildingType.empty, doublePlot: false, id: i)
        }
        
        if let spawnPoint = terrain[mapSize/2] {
            spawnPoint.setPlot(buildingType: BuildingType.townHall, doublePlot: true)
        }
        
        createTerrain()
    }
    
    func createTerrain() {
        for i in -1...2 {
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
            plot.position.x = prevPlot.position.x + plot.size.width
        } else {
            print("left-add: " + String(id))
            let prevPlot = terrain[id+1]!
            plot.position.y = prevPlot.position.y
            plot.position.x = prevPlot.position.x - plot.size.width

        }
    }
    
//    func removePlot(id : Int) {
//        self.terrain[id]?.removeFromParent()
//    }
    
    func printTerrainToConsole() {
        print(self.terrain)
    }
}
