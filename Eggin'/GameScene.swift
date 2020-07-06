//
//  GameScene.swift
//  Eggin'
//
//  Created by Benjamin Simpson on 6/25/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Obstacle: UInt32 = 0b10
    static let PlayerBody: UInt32 = 0b100
    static let Barrier: UInt32 = 0b1000
}

class GameScene: SKScene {
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 200
    var scrollNode: SKNode!
    var player: SKSpriteNode!
    var obstacleSpawner: SKNode!
    var playButton: SKSpriteNode!
    var frontBarrier: SKSpriteNode!
    
    func scrollWorld() {
      /* Scroll World */
      scrollNode.position.x -= scrollSpeed * CGFloat(fixedDelta)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        /* Set reference to scroll Node */
        if let scrollNode = self.childNode(withName: "scrollNode") {
          self.scrollNode = scrollNode
        } else {
          print("ScrollNode could not be connected properly")
        }
        
        // referecing the barrier node from the scene
        if let frontBarrier = self.childNode(withName: "frontBarrier") as? SKSpriteNode {
          self.frontBarrier = frontBarrier
        } else {
          print("frontBarrier could not be connected properly")
        }

        // setting the barrier physics body preferences
        frontBarrier.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
        frontBarrier.physicsBody?.collisionBitMask = PhysicsCategory.None
        frontBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        }

    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        /* Process world scrolling */
        scrollWorld()
    }
}
