//
//  GameScene.swift
//  Eggin'
//
//  Created by Benjamin Simpson on 6/25/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState: Equatable {
    case Active
    case Menu
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Obstacle: UInt32 = 0b10
    static let PlayerBody: UInt32 = 0b100
    static let Barrier: UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 200
    var scrollNode: SKNode!
    var player: Player!
    var obstacleSpawner: ObstacleSpawner!
    var playButton: CustomButtonNode!
    var frontBarrier: SKSpriteNode!
    var obstacleTimer: Timer!
    var gameState: GameState = .Menu{
        didSet{
            switch gameState {
            case .Active:
                          for node in player.bodyNodes{
                              node.removeFromParent()
                          }
                          player.removeAllActions()
                          self.player.bodyNodes = []
                          self.player.zRotation = 0
                          self.playButton.isHidden = true
                          self.player.position.x = self.player.initialPos.x
                          self.obstacleTimer = Timer.scheduledTimer(timeInterval: self.fixedDelta, target: self, selector: #selector(self.startGenerator), userInfo: nil, repeats: true)
                          break
                      case .Menu:
                          self.playButton.isHidden = false
                          self.obstacleTimer.invalidate()
                          for node in self.children{
                              if node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle{
                                  node.removeFromParent()
                              }
                          }
                          break
                      }
                  }
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
        
        if let playButton = self.childNode(withName: "playButton") as? CustomButtonNode {
          self.playButton = playButton
        } else {
          print("playButton was not initialized properly")
        }
        
        if let spawner = self.childNode(withName: "obstacleSpawner") as? ObstacleSpawner {
          self.obstacleSpawner = spawner
        } else {
          print("spawner could not be connected properly")
        }
        
        if let player = self.childNode(withName: "player") as? Player {
          self.player = player
        } else {
          print("player was not initialized properly")
        }
        player.setup()
        
        playButton.selectedHandler = {
        self.gameState = .Active
        }
        
        physicsWorld.contactDelegate = self
        
    }
    
    @objc func startGenerator(){
        self.obstacleSpawner.generate(scene: self.scene!)
    }
    //MARK: Check Player
    func checkPlayer(){
        if player.position.x < player.initialPos.x - 10{
            let rotate = SKAction.rotate(byAngle: 15, duration: 2.5)
            let pushBack = SKAction.moveTo(x: player.position.x - 400, duration: 2)
            let seq = SKAction.group([rotate,pushBack])
            player.run(seq)
            gameState = .Menu
        }else{
            self.player.position.x = self.player.initialPos.x
        }
    }
    
    //MARK: Check Body
    func checkBody(){
        // if we actually have nodes to check if they have been moved back more then the error margin of 5 we play an animation and remove them from the scene
        if player.bodyNodes.count >= 1 {
            for sprite in player.bodyNodes {
                if sprite.position.x < player.position.x - 5 {
                    // filter out the current node that is past the margin of error
                    player.bodyNodes = player.bodyNodes.filter {return $0 != sprite }
                    // animations
                    let rotate = SKAction.rotate(byAngle: 20, duration: 2)
                    let pushBack = SKAction.moveTo(x: sprite.position.x - 400, duration: 2)
                    // remove the node after the animation is done
                    let remove = SKAction.run {
                        sprite.removeFromParent()
                    }
                    let group = SKAction.group([pushBack, rotate])
                    let seq = SKAction.sequence([group, remove])
                    sprite.run(seq)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
    // check the categoryBitMasks to make sure we are removing the correct node.
        if bodyA.categoryBitMask == PhysicsCategory.Barrier {
            if bodyB.categoryBitMask == PhysicsCategory.Obstacle {
                bodyB.node?.removeFromParent()
            }

        }
    if bodyB.categoryBitMask == PhysicsCategory.Barrier {
        if bodyA.categoryBitMask == PhysicsCategory.Obstacle {
                bodyA.node?.removeFromParent()
            }
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            // ray that detects other nodes above the player
            let nodeCheck = physicsWorld.body(alongRayStart: player.position, end: CGPoint(x: player.position.x, y: player.position.y + 100))
            if nodeCheck?.node == nil {
                player.stack(scene: scene!)
        }
        
    }

    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        /* Process world scrolling */
        scrollWorld()
        obstacleSpawner.generate(scene: self.scene!)
        
        if gameState == .Active {
            checkBody()
            checkPlayer()
        }
    }
    
    func scrollWorld() {
      /* Scroll World */
      scrollNode.position.x -= scrollSpeed * CGFloat(fixedDelta)
    
        /* Loop through scroll layer nodes */
        for ground in scrollNode.children as! [SKSpriteNode] {

          /* Get ground node position, convert node position to scene space */
          let groundPosition = scrollNode.convert(ground.position, to: self)

          /* Check if ground sprite has left the scene */
          if groundPosition.x <= -ground.size.width / 2 {

              /* Reposition ground sprite to the second starting position */
              let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)

              /* Convert new node position back to scroll layer space */
              ground.position = self.convert(newPosition, to: scrollNode)
          }
        }
    }
}
