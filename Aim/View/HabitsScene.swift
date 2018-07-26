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
    
    var ballShape: SKShapeNode?

    override func didMove(to view: SKView) {
        let middleNode = SKShapeNode(circleOfRadius: 1)
        middleNode.position = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        middleNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        middleNode.physicsBody?.isDynamic = false
        
        middleNode.name = "helper"
        
        addChild(middleNode)
        
        
        createHabitBubble(with: view, andName: "firstBall", color: UIColor.blue, position: CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.33))
        createHabitBubble(with: view, andName: "secondBall", color: UIColor.red, position: CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.66))
        
        
        let viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.friction = 0
        self.physicsBody = viewBorder
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        self.view?.showsPhysics = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let body = physicsWorld.body(at: location) {
            if let ball = body.node as? SKShapeNode {
                ballShape = ball
                ballShape?.position = location
            }
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let ball = ballShape
            else { return }
        
        let currentLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        let ballX = ball.position.x + currentLocation.x - previousLocation.x
        let ballY = ball.position.y + currentLocation.y - previousLocation.y
        
        ball.position = CGPoint(x: ballX, y: ballY)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        ballShape = nil
    }
    
    public func createHabitBubble(with skview: SKView, andName name: String, color: UIColor, position: CGPoint) {
        let ballSprite = SKShapeNode(circleOfRadius: skview.bounds.width * 0.10)
        ballSprite.fillColor = color
        ballSprite.name = name
        ballSprite.zPosition = 1
        ballSprite.position = position
        
        ballSprite.physicsBody = SKPhysicsBody(circleOfRadius: skview.bounds.width * 0.10)
        ballSprite.physicsBody?.allowsRotation = false
//        ballSprite.physicsBody?.restitution = 0.5
//        ballSprite.physicsBody?.friction = 0.2
//        ballSprite.physicsBody?.linearDamping = 0.1
//        ballSprite.physicsBody?.angularDamping = 0
////      ballSprite.physicsBody?.mass = 0.5
        ballSprite.physicsBody?.categoryBitMask = 1
        ballSprite.physicsBody?.collisionBitMask = 1
        ballSprite.physicsBody?.usesPreciseCollisionDetection = true
        
        
        addChild(ballSprite)
        
        if let middleNode = childNode(withName: "helper") as? SKShapeNode {
            let spring = SKPhysicsJointSpring.joint(withBodyA: ballSprite.physicsBody!, bodyB: middleNode.physicsBody!, anchorA: ballSprite.position, anchorB: middleNode.position)
            spring.frequency = 0.5
            spring.damping = 0.3
            scene?.physicsWorld.add(spring)
        }
        
        
    }
}


extension HabitsScene: SKPhysicsContactDelegate {
    
}
