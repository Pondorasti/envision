//
//  HabitsScene.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit

class HabitsScene: SKScene {

    override func didMove(to view: SKView) {
        createHabitBubble(with: view, andName: "firstBall", color: UIColor.blue, position: CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.33))
        createHabitBubble(with: view, andName: "secondBall", color: UIColor.red, position: CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.66))
        
        
        let viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.friction = 0
        self.physicsBody = viewBorder
        
        physicsWorld.gravity = .zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let body = physicsWorld.body(at: location) {
            
            if body.node?.name == "firstBall" {
                print("found ball")
            }
        }
    }
    
    public func createHabitBubble(with skview: SKView, andName name: String, color: UIColor, position: CGPoint) {
        let ballSprite = SKShapeNode(circleOfRadius: skview.bounds.width * 0.25)
        ballSprite.fillColor = color
        ballSprite.name = name
        ballSprite.zPosition = 1
        ballSprite.position = position
        
        ballSprite.physicsBody = SKPhysicsBody(circleOfRadius: skview.bounds.width * 0.25)
        ballSprite.physicsBody?.allowsRotation = false
        ballSprite.physicsBody?.restitution = 0.5
        ballSprite.physicsBody?.friction = 0.2
        ballSprite.physicsBody?.linearDamping = 0.1
        ballSprite.physicsBody?.angularDamping = 0
//        ballSprite.physicsBody?.mass = 0.5
        ballSprite.physicsBody?.categoryBitMask = 1
        ballSprite.physicsBody?.collisionBitMask = 1
        
        addChild(ballSprite)
        
        ballSprite.physicsBody?.applyImpulse(CGVector(dx: -100.0, dy: 100.0))
    }
}
